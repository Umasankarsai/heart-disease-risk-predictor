# Base image with R
FROM rocker/r-ver:4.3.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    curl \
    && apt-get clean

# Install R packages
RUN R -e "install.packages(c('plumber', 'readxl', 'corrplot', 'caret', 'pROC', 'randomForest', 'xgboost', 'neuralnet', 'glmnet'))"

# Set working directory
WORKDIR /app

# Copy everything into the image
COPY . /app

# Make sure the entrypoint script is executable
RUN chmod +x /app/entrypoint.sh

# Install Python packages
RUN pip3 install --no-cache-dir -r requirements.txt

# Expose both Flask and R API ports
EXPOSE 5000 8000

# Run both Flask and R when the container starts
ENTRYPOINT ["bash", "entrypoint.sh"]
