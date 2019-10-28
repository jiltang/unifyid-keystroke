library(jsonlite)
library(data.table)
library(plyr)
library(dplyr)
library(randomForest)

args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("At least one argument must be supplied (input file URL).", call.=FALSE)
}

TARGET_STRING = "Be Authentic. Be Yourself. Be Typing."

print(paste0("getting data from ", args[1]))
dat = fromJSON(args[1])
names(dat[[1]]) = seq(1, length(dat[[1]]))
flatdat = do.call(rbind, unname(Map(cbind, entry = seq(1, length(dat[[1]])), dat[[1]])))
flatdat = flatdat %>% group_by(entry) %>% mutate(next_char = lead(character))
dat_filt = flatdat[is.na(flatdat$next_char) | (flatdat$next_char!="[backspace]" & flatdat$character!="[backspace]") ,]
phrases = ddply(dat_filt, .(entry), function(df) {paste(as.vector(df$character), collapse="")})
colnames(phrases) = c("entry", "text")
valid = phrases[phrases$text==TARGET_STRING,]

print("processing data")
qual_dat = flatdat[flatdat$entry %in% valid$entry,]
qual_phrases = phrases[phrases$entry %in% valid$entry,]
qual_dat$times = as.POSIXct(qual_dat$typed_at, tz = "UTC", "%Y-%m-%dT%H:%M:%OS") 
qual_dat$digraph = unlist(tapply(qual_dat$times, list(qual_dat$entry),
                                 FUN = function(x) c(0, `units<-`(diff(x), "secs"))))
delete_counts = plyr::count(qual_dat[qual_dat$character=="[backspace]",], c("entry"))
colnames(delete_counts) = c("entry", "del")
qual_phrases$err = adist(qual_phrases$text, TARGET_STRING) # Compute Levenshtein distance
dt = qual_dat %>% arrange(times) %>% group_by(entry) %>% slice(c(1,n()))
dt$phrasetime = unlist(tapply(dt$times, list(dt$entry),
                              FUN = function(x) c(0, `units<-`(diff(x), "secs"))))
dt = dt[dt$phrasetime!=0,]
dt = dt[,c("entry", "phrasetime")]

clean_dat = merge(dt, delete_counts, by=c("entry"), all = TRUE)
clean_dat$del[is.na(clean_dat$del)] = 0
clean_dat = merge(clean_dat, qual_phrases, by=c("entry"), all=TRUE)
clean_dat$text = NULL
clean_dat = merge(qual_dat, clean_dat, by=c("entry"), all=TRUE)
clean_dat$typed_at = NULL
chars <- unique(c(levels(as.factor(clean_dat$character)), levels(as.factor(clean_dat$next_char))))
clean_dat$character = as.numeric(factor(clean_dat$character, levels = chars))
clean_dat$next_char = as.numeric(factor(clean_dat$next_char, levels = chars))
clean_dat$times = NULL

wide_dat = clean_dat
wide_dat = wide_dat %>% group_by(entry) %>% mutate(counter = row_number())
wide_dat = wide_dat[wide_dat$counter <= 40,]
wide_dat = as.data.table(wide_dat)
wide_dat = dcast(wide_dat, entry ~ counter,
                 value.var=c("character", "next_char", "digraph"))
wide_dat = merge(wide_dat, delete_counts, by=c("entry"), all = TRUE)
wide_dat$del[is.na(wide_dat$del)] = 0
wide_dat = merge(wide_dat, qual_phrases, by=c("entry"), all=TRUE)
wide_dat$text = NULL
wide_dat = merge(wide_dat, dt, by=c("entry"), all=TRUE)

print("running model")
load("randomForest.RData") # load random forest model
traindat = na.roughfix(wide_dat) # impute missing
ypred = predict(rf_tree, newdata=traindat)
outpred = cbind(entry=traindat$entry, ypred)
out = merge(phrases, outpred, all=TRUE)
out$text = NULL
fwrite(out, "predictions.csv")
print("predictions written to predictions.csv")
