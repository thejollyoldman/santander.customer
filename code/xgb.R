# author: Ahmad Sultani
# date:   2019-03-30
# desc:   No feature engineering, applying xgboost to see what the score is

library(tidyverse)
library(xgboost)
library(data.table)
library(foreach)

# i have separated the data and code folders so i only upload code to remote repo
setwd('/home/ahmad/Documents/santander.customer')

raw_train <- fread(file = 'data/santander-customer-transaction-prediction/train.csv', sep = ',')
raw_test <- fread(file = 'data/santander-customer-transaction-prediction/test.csv', sep = ',')

summary(raw_train)
prop.table(table(raw_train$target))
# massive imbalance in the target data 90/10 split

# separate out the target, append train and test together
train_target <- raw_train$target
raw_train <- raw_train %>% select(-target)

raw_all <- union_all(raw_train, raw_test)

apply(raw_all[,-1], 2, as.numeric)

e <- data.table(raw_all[,1], )


t <- head(raw_all)
# scale all the data together (start at 2 to ignore ID)
foreach(i=2:NCOL(raw_all), .combine = 'cbind', .inorder = TRUE) %do% {
  (t[ ,..i] - mean(t[, ..i]))/sd(t[, ..i])
}
  
  
{
  t[,i] <- 
}

