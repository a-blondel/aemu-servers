# AEMU Docker Wrapper

Multi-arch Docker wrapper (`linux/amd64` + `linux/arm64`) for the **aemu** and **aemu_postoffice** servers. All upstream source is fetched and built during the Docker image build — this repository contains only Dockerfiles, compose files, and CI configuration.

## Credits

This project uses the work of [Kethen](https://github.com/Kethen):

- **aemu**: [https://github.com/Kethen/aemu](https://github.com/Kethen/aemu)
- **aemu_postoffice**: [https://github.com/Kethen/aemu_postoffice](https://github.com/Kethen/aemu_postoffice)

## Architecture

Three separate containers, each with its own image:

| Service | Image | Description | Port |
|---|---|---|---|
| `aemu-server` | `ghcr.io/a-blondel/aemu-servers/aemu-server:latest` | PSP Adhoc group management (`pspnet_adhocctl_server`) | 27312 |
| `postoffice` | `ghcr.io/a-blondel/aemu-servers/postoffice:latest` | PSP Adhoc packet relay (`aemu_postoffice`) | 27313 |
| `web` | `ghcr.io/a-blondel/aemu-servers/web:latest` | Status page and JSON API | 8080 |

`aemu-server` writes `status.xml` to a named volume (`status-data`) shared read-only with `web`. Port `27314` (postoffice debug endpoint) is internal only, consumed by the `web` container.

## Multi-arch support

Each image is a multi-arch manifest covering `linux/amd64` and `linux/arm64`. Docker automatically pulls the layer matching the host machine's architecture — no configuration needed. This works on x86 servers, Raspberry Pi, AWS Graviton, Apple Silicon (via Docker Desktop), etc.

To verify the published manifest after a workflow run:

```bash
docker manifest inspect ghcr.io/a-blondel/aemu-servers/aemu-server:latest
```

## Usage

### Basic setup

1. Copy `docker-compose.yml` to your server.
2. Start the services:

```bash
docker compose up -d

# View logs
docker compose logs -f

# Stop
docker compose down
```

That's all that's needed for a default deployment. Docker will pull the correct image for your architecture automatically.

### With customizations

If you want to override any default files (status page, CSS, game database, postoffice config), create a `custom/` directory alongside your `docker-compose.yml` and place your files there, then uncomment the relevant volume lines in `docker-compose.yml`:

```
your-server/
├── docker-compose.yml
└── custom/
    ├── database.db       # optional — replaces the default game name database
    ├── config.json       # optional — replaces the default postoffice config
    ├── status.html       # optional — replaces the default status page
    └── style.css         # optional — replaces the default stylesheet
```

The commented-out bind-mount examples are already in `docker-compose.yml`:

| File | Volume line to uncomment | Service |
|---|---|---|
| `custom/database.db` | `- ./custom/database.db:/app/database.db` | `aemu-server` |
| `custom/config.json` | `- ./custom/config.json:/app/config.json` | `postoffice` |
| `custom/status.html` | `- ./custom/status.html:/app/www/status.html:ro` | `web` |
| `custom/style.css` | `- ./custom/style.css:/app/www/style.css:ro` | `web` |

### With Traefik (HTTPS)

If you use Traefik as a reverse proxy, use the example in [`custom/docker-compose.yml`](custom/docker-compose.yml) as a starting point. It configures:

- HTTP → HTTPS redirect via Traefik middleware
- Automatic TLS certificate via Let's Encrypt (`certresolver=letsencrypt`)
- Port `8080` managed by Traefik (not exposed directly)
- Ports `27312` and `27313` still exposed directly (TCP game traffic, not HTTP)

Adapt the `Host(...)` rule to your domain and make sure the `traefik-public` external network already exists on your host.

## Updating upstream

The Dockerfiles clone the `main` branch of each upstream repository at build time. Docker layer caching means re-running the workflow without changes will not pick up new upstream commits. To pull the latest upstream source, trigger the workflow after clearing the cache, or rebuild locally with `--no-cache`:

```bash
docker compose build --no-cache
```

## Status Page

Access the status page at: [http://localhost:8080](http://localhost:8080)

JSON API endpoint: [http://localhost:8080/data.json](http://localhost:8080/data.json)
