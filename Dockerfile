FROM node:25-trixie-slim

# Install system dependencies required for aemu binary
RUN apt-get update && apt-get install -y \
    libsqlite3-0 \
    libreadline8 \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy aemu server files
COPY aemu_server/ ./aemu_server/

# Copy postoffice server files
COPY aemu_postoffice_server/ ./aemu_postoffice_server/

# Make aemu binary executable
RUN chmod +x /app/aemu_server/pspnet_adhocctl_server

# Expose ports
EXPOSE 27312
EXPOSE 27313

# Startup script to launch both servers (run aemu from its directory so it can find database.db)
CMD ["/bin/bash", "-c", "cd /app/aemu_server && ./pspnet_adhocctl_server & node /app/aemu_postoffice_server/aemu_postoffice.js & wait"]
