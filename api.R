# api.R
#* @apiTitle Heart Risk Prediction API
#* @apiDescription Predicts 10-year CHD risk using multiple models

#* @post /predict
#* @param age
#* @param totChol
#* @param sysBP
#* @param diaBP
#* @param BMI
#* @param glucose
#* @param currentSmoker
#* @param diabetes
#* @param Sex
#* @serializer json
function(age, totChol, sysBP, diaBP, BMI, glucose, currentSmoker, diabetes, Sex) {

  # Convert numeric values and map to correct factor levels
  input_data <- data.frame(
    age = as.numeric(age),
    totChol = as.numeric(totChol),
    sysBP = as.numeric(sysBP),
    diaBP = as.numeric(diaBP),
    BMI = as.numeric(BMI),
    glucose = as.numeric(glucose),
    currentSmoker = factor(ifelse(as.numeric(currentSmoker) == 1, "Yes", "No"),
                           levels = levels(framingham$currentSmoker)),
    diabetes = factor(ifelse(as.numeric(diabetes) == 1, "Yes", "No"),
                      levels = levels(framingham$diabetes)),
    Sex = factor(ifelse(as.numeric(Sex) == 1, "male", "female"),
                 levels = levels(framingham$Sex))
  )

  print("✅ Received input:")
  print(input_data)

  # Create matrix for Ridge and XGBoost
  matrix_input <- model.matrix(~ age + totChol + sysBP + diaBP + BMI + glucose + currentSmoker + diabetes + Sex, input_data)[, -1]

  tryCatch({
    list(
      logistic = as.numeric(predict(logistic_model, input_data, type = "response")),
      ridge = as.numeric(predict(ridge_model, matrix_input, s = "lambda.min", type = "response")),
      rf = as.numeric(predict(rf_model, input_data, type = "prob")[, 2]),
      xgb = as.numeric(predict(xgb_model, as.matrix(matrix_input))[1])
    )
  }, error = function(e) {
    print("❌ Prediction error:")
    print(e)
    list(error = as.character(e))
  })
}
