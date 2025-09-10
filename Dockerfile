FROM rust:1.89.0-alpine3.22 AS builder

RUN apk add --no-cache git musl-dev openssl-dev openssl-libs-static pkgconfig

WORKDIR /app
RUN git clone --depth=1 -b v0.13.1 --single-branch https://github.com/typst/typst.git

WORKDIR /app/typst
RUN cargo build -p typst-cli --release

WORKDIR /app
RUN git clone -b 20250811 --depth 1 https://github.com/trueroad/HaranoAjiFonts.git


FROM alpine:3.22.1 AS typst-alpine

COPY --from=builder /app/typst/target/release/typst /usr/local/bin/typst

CMD ["typst"]

FROM alpine:3.22.1 AS typst-jp-alpine

RUN apk add --no-cache fontconfig

COPY --from=builder /app/HaranoAjiFonts/HaranoAjiMincho-Regular.otf /usr/share/fonts/
COPY --from=builder /app/HaranoAjiFonts/HaranoAjiMincho-Bold.otf /usr/share/fonts/
COPY --from=builder /app/HaranoAjiFonts/HaranoAjiGothic-Regular.otf /usr/share/fonts/
COPY --from=builder /app/HaranoAjiFonts/HaranoAjiGothic-Bold.otf /usr/share/fonts/
COPY --from=builder /app/typst/target/release/typst /usr/local/bin/typst

RUN fc-cache -fv

CMD ["typst"]
