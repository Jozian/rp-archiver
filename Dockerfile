FROM golang:1.15-buster AS builder
ENV CGO_ENABLED=0
ARG COMPILE_FLAGS
WORKDIR /root/rp-archiver
COPY . /root/rp-archiver
RUN go build -ldflags "${COMPILE_FLAGS}" -o rp-archiver ./cmd/rp-archiver

FROM debian:buster AS rp-archiver
RUN adduser --uid 1000 --disabled-password --gecos '' --home /srv/rp-archiver rp-archiver
RUN apt-get -yq update \
        && DEBIAN_FRONTEND=noninteractive apt-get install -y \
                unattended-upgrades \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get clean
COPY --from=builder /root/rp-archiver/rp-archiver /usr/bin/
USER rp-archiver
ENTRYPOINT ["rp-archiver"]
