FROM rust:1.89.0-alpine3.22 AS builder

RUN apk add --no-cache git musl-dev openssl-dev openssl-libs-static pkgconfig

WORKDIR /app

RUN git clone --depth=1 -b v0.13.1 --single-branch https://github.com/typst/typst.git

WORKDIR /app/typst

RUN cargo build -p typst-cli --release

FROM alpine:3.22.1

COPY --from=builder /app/typst/target/release/typst /usr/local/bin/typst

CMD ["typst"]
