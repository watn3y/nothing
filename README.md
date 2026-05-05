# nothing

A Docker Container that does nothing, forever.
Useful if you need to configure other container, like traefik or caddy using labels.

> [!IMPORTANT]  
> The version of this repository you are seeing is likely a mirror.
>
> If you want to contribute any changes please head over to [git.watn3y.de](https://git.watn3y.de/watn3y/nothing) and register an account.

## Why this exists

I use [lucaslorentz/caddy-docker-proxy](https://github.com/lucaslorentz/caddy-docker-proxy) to automatically configure caddy based on docker container labels. For better readability I wanted to split-up the config into multiple containers. While it's possible to use something like ```docker run alpine:latest sleep infinity``` for this, I wanted something with a smaller image, less resource usage and a smaller attack surface.

This is where **nothing** comes in. The image is about **3,8 KB** in size and uses about **300 KiB** of memory at runtime. Due it only being made up of **18 lines of code** the attack surface is basically non existant. Problem Solved :)

## Running with Docker Compose

Docker image: <https://hub.docker.com/r/watn3y/nothing>
Docker image: <https://git.watn3y.de/watn3y/nothing/packages>

Example compose file:

```yaml
services:
  nothing:
    image: watn3y/nothing:v1.0.0
    # image: watn3y/nothing:latest # Use :latest to be up to date with the master branch on git
    container_name: nothing
    restart: unless-stopped
    labels:
      - whatever.you.want: true
```
