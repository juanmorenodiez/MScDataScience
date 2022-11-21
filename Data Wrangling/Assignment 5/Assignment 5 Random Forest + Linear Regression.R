library(randomForest)
library(caret)
library(gbm)
library(mltools)
library(data.table)
library(readr)

setwd("C:/Users/jmore/Documents/Utrecht University/Data Science/DataWrangling/Practicas/Assignment5")

# read train and test data
df_train <- read_rds("data/train.rds")
df_test <- read_rds("data/test.rds")

# definition of the mean squared error
mse <- function(y_pred, y_true) {
  mean((y_pred - y_true)^2)
}

# check if there are missing values in every column
sapply(df_train, function(x) sum(is.na(x)))

# check data types
str(df_train)

# one-hot encoding for the Factor feature types
df_train_new <- one_hot(as.data.table(df_train))

# check data types
str(df_train_new)

# correlation matrix for all the data types
correlation_matrix <- cor(df_train_new)
correlation_matrix

drop <- findCorrelation(correlation_matrix, cutoff = .8)
drop <- names(df_train_new)[drop]
drops <- c(drop)
print(drops)

df_train_new <- subset(df_train_new, select = -c(sex_F,
                                                 school_GP,
                                                 famsup_no,
                                                 higher_yes,
                                                 paid_no,
                                                 internet_no,
                                                 address_U,
                                                 schoolsup_yes,
                                                 nursery_yes,
                                                 guardian_mother,
                                                 Pstatus_A,
                                                 romantic_no,
                                                 activities_yes,
                                                 famsize_LE3
                                                 ))

str(df_train_new)

# k-fold cross validation with 10 folds
tr_control <- trainControl(method="cv", number=10, search="grid")

# grid search for finding best hyperparameters
tune_mtry_grid <- expand.grid(.mtry = c(10:20))

# create random forest model
rf_mtry <- train(score~.,
                 data = df_train_new,
                 method = "rf",
                 metric = "RMSE",
                 tuneGrid = tune_mtry_grid,
                 trControl = tr_control
                 )

# store the best mtry value
best_mtry <- rf_mtry$bestTune$mtry
print(best_mtry)

# grid search with the best mtry
tuneGrid <- expand.grid(.mtry = best_mtry)

# search of the best ntree hyperparameter value
store_maxtrees <- list()
for (ntree in c(250, 300, 350, 400, 450, 500, 550, 600, 800, 1000)) {
  set.seed(5678)
  rf_maxtrees <- train(score~.,
                       data = df_train_new,
                       method = "rf",
                       metric = "RMSE",
                       tuneGrid = tuneGrid,
                       trControl = tr_control,
                       ntree = ntree)
  key <- toString(ntree)
  store_maxtrees[[key]] <- rf_maxtrees
}

# here we get the scores for every ntree value
results_tree <- resamples(store_maxtrees)
summary(results_tree)

# creation of the model with the best values
# for mtry and ntree hyperparameters
best_model_rf <- train(score~.,
                       df_train_new,
                       method = "rf",
                       metric = "RMSE",
                       trControl = tr_control,
                       tuneGrid=tuneGrid,
                       ntree = 350)

print(best_model_rf)

# score predictions
prediction <- predict(best_model_rf, df_test)
print(prediction)

#_______________________________________Linear Regression Models_____________
# Data preparation 
# Explore data df_test
summary(df_test)
sum(is.na(df_test))
str(df_test)

# Explore data df_test
summary(df_train)
sum(is.na(df_train))
str(df_train)

# Function mean square error 
mse <- function(y_pred, y_true) {
  mean((y_pred - y_true)^2)}


# Splits training dataset into training and validation.
splits <- c(rep("train", 284), rep("validation", 32)) 
splits <- sample(splits) 

Train_master <- df_train %>%
  mutate(., splits)

Train_splitsed <- filter(df_train, splits == "train")
Validation_splitsed <- filter(df_train, splits == "validation")

# Correlation plot Training DF
df_train_cor <- df_train %>%
  select(age, Medu, Fedu, traveltime, studytime,
         failures, famrel, freetime, goout, Dalc, 
         Walc, health, absences, score) 

M <- cor(df_train_cor)
corrplot(M, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"))
#_______________________________________Linear Regression Model 1_____________

# Train Linear Regression model
model_1 <- lm(score ~ failures, data = Train_splitsed)
summary(model_1)


# Calculate MSE with this object
model_1_mse_train <- mse(y_true = Train_splitsed$score, y_pred = predict(model_1))


# Calculate MSE on validation
model_1_mse_valid <- mse(y_true = Validation_splitsed$score,
                         y_pred = predict(model_1, newdata = Validation_splitsed))



pred_vec1 <- predict(model_1, df_test)
pred_vec

#_______________________________________Linear Regression Model 2_____________

# Train Linear Regression model
model_2 <- lm(score ~ failures + famsup + activities, data = Train_splitsed)
summary(model_2)


# Calculate MSE with this object
model_2_mse_train <- mse(y_true = Train_splitsed$score, y_pred = predict(model_2))


# Calculate MSE on validation
model_2_mse_valid <- mse(y_true = Validation_splitsed$score,
                         y_pred = predict(model_2, newdata = Validation_splitsed))



pred_vec2 <- predict(model_2, df_test)
pred_vec
