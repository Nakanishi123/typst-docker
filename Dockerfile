FROM rust:1.89.0-alpine3.22 AS builder

RUN apk add --no-cache git musl-dev openssl-dev openssl-libs-static pkgconfig

WORKDIR /app
RUN git clone --depth=1 -b v0.13.1 --single-branch https://github.com/typst/typst.git

WORKDIR /app/typst
RUN cargo build -p typst-cli --release

FROM builder AS builder-jp

WORKDIR /app
RUN git clone -b 20250811 --depth 1 https://github.com/trueroad/HaranoAjiFonts.git


FROM alpine:3.22.1 AS typst-alpine

COPY --from=builder /app/typst/target/release/typst /usr/local/bin/typst

CMD ["typst"]

FROM alpine:3.22.1 AS typst-jp-alpine

RUN apk add --no-cache fontconfig

COPY --from=builder-jp /app/HaranoAjiFonts/*.otf /usr/share/fonts/
COPY --from=builder-jp /app/typst/target/release/typst /usr/local/bin/typst

RUN fc-cache -f -v

CMD ["typst"]
