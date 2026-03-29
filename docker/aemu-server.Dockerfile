# Builder stage: compile pspnet_adhocctl_server from source
FROM debian:trixie-slim AS builder

RUN apt-get update && apt-get install -y \
    gcc \
    libsqlite3-dev \
    libreadline-dev \
    make \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth=1 https://github.com/Kethen/aemu.git

WORKDIR /build/aemu

# Patch status.xml output path to /data/status.xml (shared volume with web container)
RUN sed -i 's|"www/status.xml"|"/data/status.xml"|' pspnet_adhocctl_server/config.h

# Create the dist directory expected by the Makefile, then build.
# Override CFLAGS to suppress implicit-function-declaration errors introduced
# as default errors in GCC 14 (Debian Trixie) — upstream main.c is missing
# #include <unistd.h> for close() and usleep().
RUN mkdir -p dist/server && make -C pspnet_adhocctl_server CFLAGS="-fpack-struct -I. -Wno-implicit-function-declaration"

# Runtime stage
FROM debian:trixie-slim

RUN apt-get update && apt-get install -y \
    libsqlite3-0 \
    libreadline8 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled binary and default game database from builder
COPY --from=builder /build/aemu/dist/server/pspnet_adhocctl_server ./
COPY --from=builder /build/aemu/dist/server/database.db ./

# /data is the shared volume directory: aemu-server writes status.xml here,
# web container reads it. database.db can be overridden by mounting at /app/database.db.
RUN mkdir -p /data

EXPOSE 27312

CMD ["./pspnet_adhocctl_server"]
