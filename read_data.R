library(jsonlite)
library(data.table)
library(dplyr)
library(plyr)

MAX_USERS <- 1000 # assume max of 1000 users - this makes reading faster

first <- "user_4a438fdede4e11e9b986acde48001122.json"
alldat <- vector("list", MAX_USERS) 
i <- 1
while(!is.null(first)) {
  print(paste("reading data from file", first))
  dat <- fromJSON(paste0("https://challenges.unify.id/v1/mle/", first))
  names(dat[[1]]) <- seq(1, length(dat[[1]]))
  flatdat <- do.call(rbind, unname(Map(cbind, entry = seq(1, length(dat[[1]])), dat[[1]])))
  flatdat$user <- dat[[2]]
  alldat[[i]] <- flatdat
  i <- i + 1
  first <- dat[[3]]
}
alldat[sapply(alldat, is.null)] <- NULL
alldat <- do.call(rbind, alldat)
fwrite(alldat, "raw_allusers.csv")

alldat$next_char <- lead(alldat$character)
dat_filt <- alldat[alldat$next_char!="[backspace]" & alldat$character!="[backspace]",]
phrases <- ddply(dat_filt, .(user, entry), function(df) {paste(as.vector(df$character), collapse="")})
fwrite(phrases, "phrases.csv")