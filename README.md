# AEMU Docker Wrapper

Docker wrapper to run **aemu** and **aemu_postoffice** servers in a containerized Linux environment.

## Credits

This project uses the work of [Kethen](https://github.com/Kethen):

- **aemu**: [https://github.com/Kethen/aemu](https://github.com/Kethen/aemu)
- **aemu_postoffice**: [https://github.com/Kethen/aemu_postoffice](https://github.com/Kethen/aemu_postoffice)

## Description

- **aemu** (`pspnet_adhocctl_server`): Server for PSP Adhoc traffic tunneling - Port 27312
- **aemu_postoffice**: PSP adhoc packet forwarding server - Port 27313
- **Integrated HTTP Server** (`server.js`): Web interface for server status and monitoring - Port 8080

## Usage

### With Docker Compose (using pre-built image)

```bash
# Start the servers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the servers
docker-compose down
```

### With Docker

```bash
# Build the image
docker build -t aemu-servers .

# Run the servers
docker run -d --rm -it -p 8080:8080 -p 27312:27312 -p 27313:27313 -p 27314:27314 --name aemu-servers aemu-servers:latest

# View logs
docker logs -f aemu-servers

# Stop the servers
docker stop aemu-servers
```

## Ports

- `8080`: Integrated web server (status page and JSON API)
- `27312`: aemu (pspnet_adhocctl_server)
- `27313`: aemu_postoffice
- `27314`: aemu_postoffice status endpoint

## Status Page

Access the status page at: [http://localhost:8080](http://localhost:8080)

The integrated server also provides a JSON API endpoint at: [http://localhost:8080/data.json](http://localhost:8080/data.json)
