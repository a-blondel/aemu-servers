# Builder stage: compile aemu_postoffice TypeScript to JavaScript
FROM node:25-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth=1 https://github.com/Kethen/aemu_postoffice.git

WORKDIR /build/aemu_postoffice/server_njs
RUN npm install && npm run build

# Runtime stage
FROM node:25-slim

WORKDIR /app

# Copy compiled server and default config from builder
COPY --from=builder /build/aemu_postoffice/server_njs/aemu_postoffice.js ./
COPY --from=builder /build/aemu_postoffice/server_njs/config.json ./

EXPOSE 27313
EXPOSE 27314

CMD ["node", "aemu_postoffice.js"]
