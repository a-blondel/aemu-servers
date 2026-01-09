FROM node:25-trixie-slim

# Install system dependencies required for aemu binary
RUN apt-get update && apt-get install -y \
    libsqlite3-0 \
    libreadline8 \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy aemu server files
COPY aemu_server/ ./aemu_server/

# Copy postoffice server files
COPY aemu_postoffice_server/ ./aemu_postoffice_server/

# Make aemu binary executable
RUN chmod +x /app/aemu_server/pspnet_adhocctl_server

# Configure nginx to serve www directory
RUN rm /etc/nginx/sites-enabled/default
COPY <<EOF /etc/nginx/sites-available/aemu
server {
    listen 8080;
    server_name _;
    root /app/aemu_server/www;
    index status.xml;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
RUN ln -s /etc/nginx/sites-available/aemu /etc/nginx/sites-enabled/aemu

# Expose ports
EXPOSE 27312
EXPOSE 27313
EXPOSE 8080

# Startup script to launch both servers (run aemu from its directory so it can find database.db)
CMD ["/bin/bash", "-c", "nginx && cd /app/aemu_server && ./pspnet_adhocctl_server & node /app/aemu_postoffice_server/aemu_postoffice.js & wait"]
