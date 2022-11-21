####
# Assigment 5
####

# library 
library(tidyverse)
library(glmnet) 
library(magrittr)
library(lattice)
library(correlation)
library(ggcorrplot)
library(see)
library(caret)
library(fastDummies)
library(Metrics)


setwd("C:/Users/jmore/Documents/Utrecht University/Data Science/DataWrangling/Practicas/Assignment5")

df_train <- read_rds("data/train.rds")
df_test <- read_rds("data/test.rds")

# check for missing values
sum(is.na(df_train))

# explore
summary(df_train)

str(df_train)


# Correlation numeric
# Pearson's 

df_train %>%
  select(age, Medu, Fedu, traveltime, studytime,
         failures, famrel, freetime, goout, Dalc, 
         Walc, health, absences, score) %>% 
  correlation(include_factors = TRUE, method = "auto") %>%
  summary() %>%
  plot(show_labels=TRUE,
       show_p=TRUE,
       size_point=5,
       size_text=4,
       digits=2,
       type="tile",
  )

# Categorical atributes with more than 2 categories
# Cramer’s V

df_train %>%
select(Mjob, Fjob, reason, guardian, score) %>% 
  assoc() %>%
  print(digits = 2)

# Binary atributtes
df_train %>%
  select(school, sex, famsize, address, Pstatus,
         famsup, paid, activities, nursery, higher, 
         internet, romantic, score) %>% 
  assoc() %>%
  print(digits = 2)

# Lasso regression 

# set seed
set.seed(134)

# split in train and valid
train_index <- createDataPartition(df_train$score, p = .8, 
                                   list = FALSE, 
                                   times = 1)

dfinal_train <- df_train[train_index,]

df_valid <- df_train[-train_index,]

# We will apply One Hot Encoding in the categorical variables in training data
dummy_train <- dummyVars(" ~ .", data = dfinal_train)

# transform in a data frame
final_train_ <- data.frame(predict(dummy_train, newdata = dfinal_train)) #!!!

final_train <- final_train_ %>% 
                 select(-score)

# transform in a matrix
train_matrix <- as.matrix(final_train)


# Using cross-validation to find the best lambda
lasso_cv <- cv.glmnet(x = train_matrix, 
                      y = dfinal_train$score,
                      nfolds = 15, 
                      alpha = 1, 
                      family = "gaussian")

# Assessing the best lambda
best_lambda <- lasso_cv$lambda.min

best_lambda

# plot
plot(lasso_cv)

# Knowing the best lambda, we will run the model
lasso_model <- glmnet(x = train_matrix, 
                      y = dfinal_train$score,
                      alpha = 1, 
                      lambda = best_lambda)
coef(lasso_model)

# Getting the MSE in the train set
mse_train <- lasso_cv$cvm[lasso_cv$lambda == best_lambda]

mse_train # 0.8451153

# Performance in the test set

# apply One Hot Encoding in the categorical variables in test data
dummy_test <- dummyVars(" ~ .", data = df_test)

# transform in a data frame
final_test <- data.frame(predict(dummy_test, newdata = df_test))

# transform in a matrix
test_matrix <- as.matrix(final_test)

# prediction 
lasso_pred <- data.frame(predict(lasso_model, s = best_lambda, newx = test_matrix))

### MSE validation 

dummy_valid <- dummyVars(" ~ .", data = df_valid)

# transform in a data frame
final_valid_ <- data.frame(predict(dummy_valid, newdata = df_valid))

final_valid <- final_valid_ %>% 
  select(-score)

# transform in a matrix
valid_matrix <- as.matrix(final_valid)

# mse in the validation 
mse_valid <- mse(df_valid$score, predict(lasso_model, valid_matrix))
mse_valid # 0.726242

# generate the precitions 
lasso_pred
write_rds(lasso_pred, file = "pred_06.rds")
