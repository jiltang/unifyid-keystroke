library(jsonlite)
library(data.table)
library(plyr)
library(dplyr)

MAX_USERS = 1000 # assume max of 1000 users - this makes reading faster
TARGET_STRING = "Be Authentic. Be Yourself. Be Typing."
MIN_VALID = 300

first = "user_4a438fdede4e11e9b986acde48001122.json"
alldat = vector("list", MAX_USERS) 
i = 1
while(!is.null(first)) {
  print(paste("reading data from file", first))
  dat = fromJSON(paste0("https://challenges.unify.id/v1/mle/", first))
  names(dat[[1]]) = seq(1, length(dat[[1]]))
  flatdat = do.call(rbind, unname(Map(cbind, entry = seq(1, length(dat[[1]])), dat[[1]])))
  flatdat$user = dat[[2]]
  alldat[[i]] = flatdat
  i = i + 1
  first = dat[[3]]
}
alldat[sapply(alldat, is.null)] = NULL
alldat = do.call(rbind, alldat)
fwrite(alldat, "allusers_raw.csv", quote=TRUE) # Set quotes to not lose whitespace

print("Processing user data...")
alldat = alldat %>% group_by(user, entry) %>% mutate(next_char = lead(character))
dat_filt = alldat[is.na(alldat$next_char) | (alldat$next_char!="[backspace]" & alldat$character!="[backspace]") ,]
phrases = ddply(dat_filt, .(user, entry), function(df) {paste(as.vector(df$character), collapse="")})
colnames(phrases) = c("user", "entry", "text")
valid = phrases[phrases$text==TARGET_STRING,]
user_counts = plyr::count(valid, "user")
valid_users = user_counts[user_counts$freq >= MIN_VALID,]
fwrite(valid_users, "qualified_users.csv", quote=TRUE)

print("Making list of disqualified users")
invalid_users = user_counts[user_counts$freq < MIN_VALID,]
fwrite(invalid_users, "disqualified_users.csv", quote=TRUE)

print("Filtering by qualified users")
qual_dat = alldat[alldat$user %in% valid_users$user,]
fwrite(qual_dat, "qualified_raw.csv", quote=TRUE)
qual_phrases = phrases[phrases$user %in% valid_users$user,]
fwrite(qual_phrases, "qualified_phrases.csv", quote=TRUE)

print("Calculating new features")

# timezone doesn't matter since we want difference
qual_dat$times = as.POSIXct(qual_dat$typed_at, tz = "UTC", "%Y-%m-%dT%H:%M:%OS") 
qual_dat$digraph = unlist(tapply(qual_dat$times, list(qual_dat$entry, qual_dat$user),
                            FUN = function(x) c(0, `units<-`(diff(x), "secs"))))

# Get errors
delete_counts = plyr::count(qual_dat[qual_dat$character=="[backspace]",], c("user", "entry"))
colnames(delete_counts) = c("user", "entry", "del")
qual_phrases$err = adist(qual_phrases$text, TARGET_STRING) # Compute Levenshtein distance

# Get times to type entire phrase
dt = qual_dat %>% arrange(times) %>% group_by(user, entry) %>% slice(c(1,n()))
dt$phrasetime = unlist(tapply(dt$times, list(dt$entry, dt$user),
                              FUN = function(x) c(0, `units<-`(diff(x), "secs"))))
dt = dt[dt$phrasetime!=0,]
dt = dt[,c("user", "entry", "phrasetime")]

# Write file with new features
clean_dat = merge(dt, delete_counts, by=c("user", "entry"))
clean_dat = merge(clean_dat, qual_phrases, by=c("user", "entry"))
clean_dat$text = NULL
clean_dat = merge(qual_dat, clean_dat, by=c("user", "entry"), all.x=TRUE)
fwrite(clean_dat, "qualified_clean.csv", quote = TRUE)

