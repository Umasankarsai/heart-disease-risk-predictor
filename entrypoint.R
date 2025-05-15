cat("✅ Starting entrypoint.R...\n")
library(plumber)
library(readxl)
library(randomForest)
library(xgboost)
library(glmnet)

tryCatch({
  cat("📦 Loading dataset...\n")
  framingham <- read_excel("data/framingham.xlsx")
  framingham$currentSmoker <- as.factor(framingham$currentSmoker)
  framingham$diabetes <- as.factor(framingham$diabetes)
  framingham$Sex <- as.factor(framingham$Sex)

  cat("📦 Loading models...\n")
  logistic_model <<- readRDS("models/logistic_model.rds")
  ridge_model <<- readRDS("models/ridge_model.rds")
  rf_model <<- readRDS("models/rf_model.rds")
  xgb_model <<- readRDS("models/xgb_model.rds")

  cat("🚀 Starting Plumber API...\n")
  pr <- plumb("api.R")

  # ✅ Enable Swagger docs
  pr$setDocs(TRUE)

  pr$run(host = "0.0.0.0", port = 8000)

}, error = function(e) {
  cat("❌ Error during startup:\n")
  print(e)
  quit(status = 1)
})