FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV HTTPX_VERSION=1.6.10

# Install curl, unzip and certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Download and install httpx binary
RUN curl -sSLo /tmp/httpx.zip "https://github.com/projectdiscovery/httpx/releases/download/v${HTTPX_VERSION}/httpx_${HTTPX_VERSION}_linux_amd64.zip" \
    && unzip -o /tmp/httpx.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/httpx \
    && rm /tmp/httpx.zip

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV HOST=0.0.0.0
EXPOSE 8000

CMD ["python", "server.py"]
