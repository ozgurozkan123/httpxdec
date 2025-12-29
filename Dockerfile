FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV HTTPX_VERSION=1.6.10

# Install curl and ca certificates, then download httpx binary
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSLo /tmp/httpx.tar.gz "https://github.com/projectdiscovery/httpx/releases/download/v${HTTPX_VERSION}/httpx_${HTTPX_VERSION}_linux_amd64.tar.gz" \
    && tar -xzf /tmp/httpx.tar.gz -C /usr/local/bin httpx \
    && chmod +x /usr/local/bin/httpx \
    && rm /tmp/httpx.tar.gz

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV HOST=0.0.0.0
EXPOSE 8000

CMD ["python", "server.py"]
