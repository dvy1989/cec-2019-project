# This version is installed at this computer, that is why such a base image is used
FROM python:3.7.2-slim

# Set working directory
WORKDIR /app

# Copy all files to that directory (Dockerfile assumed to be ignored)
COPY . /app

# Install missing packets
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Expose port
EXPOSE 80

# Run server
CMD ["python", "load-balancer.py"]

