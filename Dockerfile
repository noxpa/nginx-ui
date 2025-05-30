FROM golang:1.23.4-bullseye AS builder
WORKDIR /app
COPY . .

RUN sed -i 's|http://deb.debian.org/debian|http://mirrors.aliyun.com/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org|http://mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y git build-essential

RUN make


FROM debian:bullseye-slim

WORKDIR /app

# 替换为阿里云源，加速 apt 安装
RUN sed -i 's|http://deb.debian.org/debian|http://mirrors.aliyun.com/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y nginx bash

RUN mkdir -p /etc/nginx/sites-enabled
RUN nginx

COPY --from=builder /app/uranus .

ENV GIN_MODE=release
EXPOSE 7777
CMD ["/app/uranus"]
