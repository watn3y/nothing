# nothing

A Docker Container that does nothing, forever.
Useful if you need to configure other container, like traefik or caddy using labels.

## Running with Docker Compose

Docker image: <https://hub.docker.com/r/watn3y/nothing>

Example compose file:

```yaml
services:
  nothing:
    image: watn3y/nothing:latest
    container_name: nothing
    restart: unless-stopped
    labels:
      - whatever.you.want: true
```
