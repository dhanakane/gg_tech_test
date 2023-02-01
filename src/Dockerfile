FROM golang:latest as builder

WORKDIR /app
COPY go.mod go.sum main.go /app/.
RUN go mod download
RUN CGO_ENABLED=0 go build -v -o app .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app ./
EXPOSE 8080
ENV PORT=8080
CMD ["./app"]
