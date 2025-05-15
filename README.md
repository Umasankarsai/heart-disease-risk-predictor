# heart-disease-risk-predictor
ML-powered heart disease risk predictor using R + Flask, deployed on Google Cloud Run.
# 🫀 Heart Disease Risk Prediction using Machine Learning

This project is part of my final year MS in Applied Statistics & Analytics at Central Michigan University. The goal is to predict the risk of heart disease based on user input using machine learning models developed in R and deployed via a REST API, integrated with a Flask-based frontend.

## 🚀 Project Overview

This application predicts the probability of heart disease using the **Framingham Heart Study dataset**. It integrates R for model training and prediction with a Python Flask frontend hosted on **Google Cloud Run**.

## 💡 Key Features

🔸 Trained multiple ML models in R (Logistic Regression, Decision Trees, Perceptron)  
🔸 Built RESTful API using `Plumber` in R to serve model predictions  
🔸 Created a user interface with `Flask` in Python for input and result visualization  
🔸 Deployed the full application using `Google Cloud Run`  
🔸 Achieved dynamic, real-time risk assessment via API integration

## 🛠️ Tech Stack

- **Languages:** R, Python  
- **Frontend:** Flask + HTML/CSS  
- **API:** R Plumber  
- **Deployment:** Google Cloud Run  
- **Version Control:** Git + GitHub  
- **Others:** Tidyverse, Scikit-learn, Google Cloud SDK

## 📊 Dataset

- Source: Framingham Heart Study  
- Processed features include: age, cholesterol, blood pressure, BMI, smoking status, etc.  
- Target: Binary classification of heart disease risk

## 🌐 Live Demo

👉 [View the live deployed app](https://heart-risk-app-802586937044.us-central1.run.app)

## 🙏 Acknowledgements

Special thanks to **Dr. Patrick Kinnicutt** at CMU for the continuous support and mentorship throughout the development of this project.


## 📁 How to Run (Locally)

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/heart-disease-risk-predictor.git
   cd heart-disease-risk-predictor
