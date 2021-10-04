FROM golang:latest
COPY . /nautible-ac
WORKDIR /nautible-ac
RUN GOOS=linux GOARCH=amd64 go build -o nautible-ac

FROM ubuntu:latest
COPY --from=0 /nautible-ac/nautible-ac /usr/local/bin/nautible-ac
