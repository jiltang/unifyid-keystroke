library(randomForest)

dat = fread("clean_wide.csv")
# Remove the 41st keystroke since it so rarely occurs
dat$character_41 = NULL
dat$next_char_41 = NULL
dat$digraph_41 = NULL
dat$user = factor(dat$user)

set.seed(1)
train = sample(1:nrow(dat), 15000) # Split into test and train
rf_tree = randomForest(user ~ . - entry, data=dat, subset=train,
             mtry=13,importance =TRUE, na.action=na.roughfix) # imputes missing
rf_tree

traindat = dat[-train, ]
yreal = traindat$user
traindat$user = NULL
traindat = na.roughfix(traindat) # impute missing
ypred = predict(rf_tree, newdata=traindat)
print("confusion matrix:")
table(ypred, yreal)
print("accuracy: ")
sum(ypred==yreal)/length(yreal)
print("user level accuracy:")
for(user in levels(yreal)) {
  traindat = dat[-train, ]
  traindat = traindat[traindat$user == user]
  yreal = traindat$user
  traindat$user = NULL
  traindat = na.roughfix(traindat) # impute missing
  ypred = predict(rf_tree, newdata=traindat)
  
  print(paste0("accuracy for user ", user, ": ", sum(ypred==yreal)/length(yreal)))
}

save(rf_tree, file="randomForest.RData") # Saves the model
