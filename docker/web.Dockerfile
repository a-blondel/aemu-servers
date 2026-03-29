# Builder stage: clone and patch server files
FROM node:25-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth=1 https://github.com/Kethen/aemu.git

WORKDIR /build/aemu/pspnet_adhocctl_server/www

# Patch postoffice data URL to use environment variable (falls back to localhost for standalone use)
RUN sed -i 's|const postoffice_data_url = "http://127.0.0.1:27314"|const postoffice_data_url = process.env.POSTOFFICE_URL ?? "http://127.0.0.1:27314"|' server.js

# Patch status.xml read path to match aemu-server's write path (/data/status.xml)
RUN sed -i 's|fs.readFile("./status.xml"|fs.readFile("/data/status.xml"|' server.js

# Runtime stage
FROM node:25-slim

WORKDIR /app/www

# Copy patched server and all static files (status.html, style.css, fxparser/, etc.)
COPY --from=builder /build/aemu/pspnet_adhocctl_server/www/ ./

# Default postoffice URL — override via environment variable or docker-compose
ENV POSTOFFICE_URL=http://postoffice:27314

EXPOSE 8080

CMD ["node", "server.js"]
