FROM golang:1.23-alpine3.20 AS builder

COPY . /github.com/pu4mane/auth-api/source/
WORKDIR /github.com/pu4mane/auth-api/source/

RUN go mod download
RUN go build -o ./bin/auth-api cmd/grpc_server/main.go

FROM alpine:3.20

WORKDIR /root/
COPY --from=builder /github.com/pu4mane/auth-api/source/bin/auth-api .
COPY --from=builder /github.com/pu4mane/auth-api/source/local.env .

CMD ["./auth-api", "-config=local.env"]