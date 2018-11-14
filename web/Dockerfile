# BUILD
FROM golang:1.9.1-alpine3.6 as builder

RUN apk add --update \
    git \
  && rm -rf /var/cache/apk/*

WORKDIR /go/src/dispatcher

COPY Gopkg.lock .
COPY Gopkg.toml .
COPY dispatcher.go .

RUN go get -u github.com/golang/dep/cmd/dep 
RUN dep ensure

RUN go build dispatcher.go

# RUN
FROM alpine:edge

EXPOSE 80
CMD ["/dispatcher"]

COPY --from=builder /go/src/dispatcher/dispatcher /
COPY static /static/
