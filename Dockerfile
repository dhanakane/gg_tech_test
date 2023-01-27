FROM golang:latest as builder

WORKDIR /app
COPY go.mod go.sum main.go /app/.
RUN go mod download
ENV PORT=9999
ENV GIN_MODE=debug
ENV REDIS_HOST=locahost
ENV REDIS_PASSWORD=test
ENV REDIS_DB=0
RUN CGO_ENABLED=0 go build -v -o app .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app ./
EXPOSE 9999
CMD ["./app"]
