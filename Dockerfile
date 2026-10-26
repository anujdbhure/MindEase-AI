# ---- base image ----
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy dependency list first (layer cache friendly)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY . .

# Expose the Flask port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
