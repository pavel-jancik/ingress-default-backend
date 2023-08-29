FROM docker.io/golang:alpine as builder
RUN set -x \
  && addgroup -S golang \
  && adduser -S -u 10000 -g golang golang

RUN set -x \
 && apk update \
 && apk add --no-cache musl-dev gcc build-base

WORKDIR /go/src/app
COPY . .
RUN CGO_ENABLED=0 go build -ldflags '-linkmode "external" -extldflags "-static"'

FROM scratch
COPY --from=builder /go/src/app/ingress-default-backend /ingress-default-backend
USER 10000
EXPOSE 8080
ENTRYPOINT ["/ingress-default-backend"]