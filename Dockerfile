FROM docker.io/golang:1.24.5-alpine AS builder
RUN set -x \
  && addgroup -S golang \
  && adduser -S -u 10000 -g golang golang

RUN set -x \
 && apk update \
 && apk add --no-cache musl-dev gcc build-base

WORKDIR /go/src/app
COPY . .
RUN CGO_ENABLED=0 go build

FROM scratch
COPY --from=builder /go/src/app/ingress-default-backend /ingress-default-backend
USER 10000:10000
EXPOSE 8080
ENTRYPOINT ["/ingress-default-backend"]
