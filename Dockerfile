# Use Python 3.12 slim image to match local env and reduce size
FROM python:3.12-slim

# Prevent Python from writing .pyc files and enable unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies (git for pip VCS if needed; build tools minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Install Python dependencies first for better layer caching
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY . .

# Default environment file can be supplied at runtime with --env-file .env
# Expose a common port if the web UI/gateway is used; adjust as needed
EXPOSE 8080

# Use a non-root user for safety
RUN useradd -m appuser
USER appuser

# Default command to run the Solace Agent Mesh
# If "sam" is provided by solace-agent-mesh package, it should be on PATH after pip install
CMD ["sam", "run"]
