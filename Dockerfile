FROM alpine:latest AS builder

RUN apk add --no-cache musl-dev gcc

WORKDIR /nothing
COPY main.c .
RUN gcc -Os -static -o nothing main.c && strip nothing


FROM scratch
LABEL org.opencontainers.image.source=https://github.com/watn3y/nothing
LABEL org.opencontainers.image.licenses=GPL-3.0

COPY --from=builder /nothing/nothing /app/nothing

ENTRYPOINT ["/app/nothing"]
