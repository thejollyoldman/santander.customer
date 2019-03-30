# author: Ahmad Sultani
# date:   2019-03-30
# desc:   No feature engineering, applying xgboost to see what the score is

library(tidyverse)
library(xgboost)
library(data.table)
library(foreach)
library(doParallel)

# i have separated the data and code folders so i only upload code to remote repo
setwd('/home/ahmad/Documents')

raw_train <- fread(file = 'data/santander-customer-transaction-prediction/train.csv', sep = ',')
raw_test <- fread(file = 'data/santander-customer-transaction-prediction/test.csv', sep = ',')

summary(raw_train)
prop.table(table(raw_train$target))
# massive imbalance in the target data 90/10 split

# separate out the target, append train and test together, separate out ID, delete test/train, convert to matrix, remove ID
train_target <- as.numeric(raw_train$target)
raw_train <- raw_train %>% select(-target)

raw_all <- union_all(raw_train, raw_test)
raw_all_ID_code <- raw_all$ID_code
raw_all$ID_code <- NULL

raw_test <- NULL
raw_train <- NULL

raw_all_mat <- as.matrix(raw_all)

#####################################################################################################################################

# in this section, any additional feature generation/engineering can be handled outside of this code (this is purely for initial 
# wrangling, hyperparameter search and model build)

#####################################################################################################################################

# scale all the data together (start at 2 to ignore ID)
# we apply parallel process here
cl <- makePSOCKcluster(4, methods = FALSE) # we don't want to load methods package. App 30% saving
registerDoParallel(cl)

    scal_raw_all_mat <- foreach(i=1:NCOL(raw_all_mat), .combine = 'cbind') %dopar% { 
                                 (raw_all_mat[ ,i] - mean(raw_all_mat[, i]))/sd(raw_all_mat[, i])
                        }
    
stopCluster(cl)

# change column names to match back up
colnames(scal_raw_all_mat) <- str_c("var", as.numeric(str_replace(colnames(scal_raw_all_mat), "result.", "")) - 1, sep = "_")

# create xgb matrix using scal_rawl_all_mat
ftrain <- scal_raw_all_mat[str_detect(raw_all_ID_code, "train"), ]
ftest <- scal_raw_all_mat[str_detect(raw_all_ID_code, "test"), ]

# create row weights for ftrain for xgboost
train_weights <- ifelse(train_target == 0, table(train_target)[2] / table(train_target)[1], 1)

#create xgboost training/test matricies
dtrain <- xgb.DMatrix(data = ftrain, label = as.numeric(train_target), weight = train_weights)
dtest <- xgb.DMatrix(data = ftest)

# hyperparameter search and pull out best cross validation 
# after say 100 iterations parallel on 5 threads (if it can handle)


# run model with given hyperparameters


# score train and calculate in time validation


# create final table with all target variables calculated for upload to kaggle


