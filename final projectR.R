  # --- Package Installation (run only once) ---
  if(!require("readxl")) install.packages("readxl")
if(!require("corrplot")) install.packages("corrplot")
if(!require("caret")) install.packages("caret")
if(!require("pROC")) install.packages("pROC")
if(!require("randomForest")) install.packages("randomForest")
if(!require("xgboost")) install.packages("xgboost")
if(!require("neuralnet")) install.packages("neuralnet")
if(!require("glmnet")) install.packages("glmnet")

# --- Load Libraries ---
library(readxl)
library(corrplot)
library(caret)
library(pROC)
library(randomForest)
library(xgboost)
library(neuralnet)
library(glmnet)

# --- Step 1: Load the Dataset ---
framingham <- read_excel("C:/Users/gvuma/Downloads/framingham (1).xlsx")

# --- Convert Columns to Numeric ---
# List of columns that should be numeric
numeric_cols <- c("age", "cigsPerDay", "totChol", "sysBP", "diaBP", "BMI", "heartRate", "glucose")
for(col in numeric_cols){
  framingham[[col]] <- as.numeric(as.character(framingham[[col]]))
}

# Check structure after conversion
str(framingham)

# --- Step 2: Data Cleaning ---
# Check for missing values
print(colSums(is.na(framingham)))

# Impute missing values for numerical variables with their mean (if any)
for(col in numeric_cols) {
  if(any(is.na(framingham[[col]]))) {
    framingham[[col]][is.na(framingham[[col]])] <- mean(framingham[[col]], na.rm = TRUE)
  }
}

# Define a function for mode imputation for categorical/binary variables
mode_impute <- function(x) {
  unique_x <- unique(x[!is.na(x)])
  unique_x[which.max(tabulate(match(x, unique_x)))]
}

# Impute missing values for binary variables (if any)
if(any(is.na(framingham$currentSmoker))) {
  framingham$currentSmoker[is.na(framingham$currentSmoker)] <- mode_impute(framingham$currentSmoker)
}
if(any(is.na(framingham$diabetes))) {
  framingham$diabetes[is.na(framingham$diabetes)] <- mode_impute(framingham$diabetes)
}

# Convert appropriate columns to factors
framingham$Sex <- as.factor(framingham$Sex)
framingham$currentSmoker <- as.factor(framingham$currentSmoker)
framingham$TenYearCHD <- as.factor(framingham$TenYearCHD)
framingham$diabetes <- as.factor(framingham$diabetes)

# --- Step 3: Exploratory Data Analysis (EDA) ---
# Summary statistics
summary(framingham)

# Histogram for total cholesterol
hist(framingham$totChol, main = "Total Cholesterol Levels", 
     xlab = "Cholesterol", col = "lightblue")

# Boxplot for systolic blood pressure
boxplot(framingham$sysBP, main = "Systolic Blood Pressure", 
        ylab = "Pressure (mmHg)", col = "orange")

# Correlation matrix for numerical variables
numeric_vars <- framingham[, sapply(framingham, is.numeric)]
corrplot(cor(numeric_vars, use = "complete.obs"), method = "circle")

# Class distribution of TenYearCHD
print(table(framingham$TenYearCHD))

# --- Step 4: Logistic Regression ---
# Fit the logistic regression model
model <- glm(TenYearCHD ~ age + totChol + sysBP + diaBP + BMI + glucose + currentSmoker + diabetes + Sex,
             data = framingham, family = binomial)

# Summary of the model
summary(model)

# Calculate and print odds ratios
print(exp(coef(model)))

# Add predicted probabilities to the dataset
framingham$predicted_risk <- predict(model, framingham, type = "response")

# --- Step 5: Model Evaluation ---
# Create a binary classification (cutoff = 0.5)
framingham$predicted_class <- ifelse(framingham$predicted_risk > 0.5, 1, 0)

# Confusion matrix
confusionMatrix(as.factor(framingham$predicted_class), framingham$TenYearCHD)

# ROC Curve and AUC
roc_curve <- roc(framingham$TenYearCHD, framingham$predicted_risk)
plot(roc_curve, main = "ROC Curve", col = "blue")
print(auc(roc_curve))

# --- Step 6: Logistic Regression with Regularization (Ridge) ---
x <- model.matrix(TenYearCHD ~ age + totChol + sysBP + diaBP + BMI + glucose + currentSmoker + diabetes + Sex, framingham)[,-1]
y <- framingham$TenYearCHD

# Convert the factor variable TenYearCHD to numeric (0 or 1)
y <- as.numeric(framingham$TenYearCHD) - 1  # Convert factor levels to 0 and 1

# Fit the ridge regression model
ridge_model <- cv.glmnet(x, y, alpha = 0)  # L2 Regularization (Ridge)

# Summary of the ridge model
print(ridge_model)

# Predict using the ridge model
framingham$ridge_predicted_risk <- predict(ridge_model, s = "lambda.min", newx = x, type = "response")

# --- Step 7: Random Forest Model ---
rf_model <- randomForest(TenYearCHD ~ age + totChol + sysBP + diaBP + BMI + glucose + currentSmoker + diabetes + Sex,
                         data = framingham, ntree = 500)

# Predict using Random Forest
framingham$rf_predicted_risk <- predict(rf_model, framingham, type = "response")

# --- Step 8: XGBoost Model ---
# Convert categorical variables to numeric (one-hot encoding or factor conversion)
train_data <- model.matrix(~ age + totChol + sysBP + diaBP + BMI + glucose + currentSmoker + diabetes + Sex - 1, framingham)

# Convert the target variable (TenYearCHD) to numeric (0/1)
train_label <- as.numeric(framingham$TenYearCHD) - 1  # Convert factor levels to 0 and 1

# Train the XGBoost model
xgb_model <- xgboost(data = train_data, label = train_label, nrounds = 100, objective = "binary:logistic")

# Predict using XGBoost
framingham$xgb_predicted_risk <- predict(xgb_model, train_data)



# --- Step 10: Model Evaluation ---
# ROC and AUC for each model

# Logistic Regression ROC
roc_curve_log_reg <- roc(framingham$TenYearCHD, framingham$predicted_risk)
plot(roc_curve_log_reg, main = "Logistic Regression ROC Curve", col = "blue")
print(auc(roc_curve_log_reg))

# Ridge Regularization ROC
roc_curve_ridge <- roc(framingham$TenYearCHD, framingham$ridge_predicted_risk)
plot(roc_curve_ridge, main = "Ridge Regularization ROC Curve", col = "green")
print(auc(roc_curve_ridge))

# Random Forest ROC
# Assuming your random forest model is trained and you need the probability predictions:
rf_pred_probs <- predict(rf_model, framingham, type = "prob")[, 2]  # Assuming '1' is the positive class

# Now, plot the ROC for Random Forest
roc_curve_rf <- roc(framingham$TenYearCHD, rf_pred_probs)
plot(roc_curve_rf, main = "Random Forest ROC Curve", col = "red")
print(auc(roc_curve_rf))

# XGBoost ROC
roc_curve_xgb <- roc(framingham$TenYearCHD, framingham$xgb_predicted_risk)
plot(roc_curve_xgb, main = "XGBoost ROC Curve", col = "orange")
print(auc(roc_curve_xgb))



# --- Step 11: Save All Models ---
saveRDS(model, "C:/Users/gvuma/Desktop/final ms R/logistic_model.rds")
saveRDS(ridge_model, "C:/Users/gvuma/Desktop/final ms R/ridge_model.rds")
saveRDS(rf_model, "C:/Users/gvuma/Desktop/final ms R/rf_model.rds")
saveRDS(xgb_model, "C:/Users/gvuma/Desktop/final ms R/xgb_model.rds")

