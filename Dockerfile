# Use Alpine Linux as base image
FROM alpine:latest

# Set working directory
WORKDIR /app

# Install Python and system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    gcc \
    musl-dev \
    linux-headers \
    && rm -rf /var/cache/apk/*; python -m venv venv;

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt;

# Copy source code to /app
COPY src/ .

# Expose port 2000
EXPOSE 7000

# Run the application with gunicorn
CMD ["/app/venv/bin/gunicorn", "--bind", "0.0.0.0:7000", "wsgi:application"]
