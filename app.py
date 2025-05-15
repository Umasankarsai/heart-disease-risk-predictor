from flask import Flask, render_template, request, redirect, session, url_for
import requests
import time

app = Flask(__name__)
app.secret_key = 'your_secret_key_here'  # Replace with something secure in production

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        input_data = {
            "age": request.form["age"],
            "totChol": request.form["totChol"],
            "sysBP": request.form["sysBP"],
            "diaBP": request.form["diaBP"],
            "BMI": request.form["BMI"],
            "glucose": request.form["glucose"],
            "currentSmoker": request.form["currentSmoker"],
            "diabetes": request.form["diabetes"],
            "Sex": request.form["Sex"]
        }

        # 🔁 Give R Plumber a moment to start (especially in Docker/Cloud Run)
        time.sleep(3)

        try:
            # 🛠 Use localhost instead of 127.0.0.1 for compatibility in containers
            response = requests.post("http://localhost:8000/predict", json=input_data, timeout=10)
            raw_result = response.json()

            print("🔍 Raw API response:", raw_result)  # Debug print

            if "error" in raw_result:
                raise ValueError(raw_result["error"])

            prediction = {}
            for k, v in raw_result.items():
                try:
                    prediction[k] = float(v[0]) if isinstance(v, list) else float(v)
                except (ValueError, TypeError):
                    print(f"⚠️ Error converting {k}: {v}")
                    prediction[k] = 0.0

            session['prediction'] = prediction
            session['best_model'] = max(prediction, key=prediction.get)

        except Exception as e:
            print("🚨 Exception while processing API response:", e)
            session['prediction'] = {"error": str(e)}
            session['best_model'] = None

        return redirect(url_for('index'))

    # GET request - retrieve and clear session data
    prediction = session.pop('prediction', None)
    best_model = session.pop('best_model', None)

    return render_template("index.html", prediction=prediction, best=best_model)

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=8080)
