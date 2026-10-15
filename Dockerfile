FROM alpine:latest AS builder

RUN apk add --no-cache musl-dev gcc

WORKDIR /nothing
COPY main.c .
RUN gcc -Os -static -o nothing main.c && strip nothing


FROM scratch
LABEL org.opencontainers.image.title="nothing" \
    org.opencontainers.image.description="A Docker Container that does nothing, forever. Useful if you need to configure other container, like traefik or caddy using labels." \
    org.opencontainers.image.authors="watn3y <me@watn3y.de>" \
    org.opencontainers.image.vendor="watn3y" \
    org.opencontainers.image.documentation="https://git.watn3y.de/watn3y/nothing/src/branch/master/README.md" \
    org.opencontainers.image.url="https://git.watn3y.de/watn3y/nothing" \
    org.opencontainers.image.source="https://git.watn3y.de/watn3y/nothing" \
    org.opencontainers.image.licenses="GPL-3.0-or-later" 

COPY --from=builder /nothing/nothing /app/nothing

ENTRYPOINT ["/app/nothing"]
