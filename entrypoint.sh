#!/bin/bash

echo "🔁 Starting R Plumber API..."
Rscript /app/entrypoint.R &

echo "🚀 Starting Flask app..."
python3 /app/app.py
