FROM golang:1.18-buster AS builder
ENV CGO_ENABLED=0
ARG COMPILE_FLAGS
WORKDIR /root/rp-archiver
COPY go.mod /root/rp-archiver/go.mod
COPY go.sum /root/rp-archiver/go.sum
RUN go mod download
COPY . /root/rp-archiver
RUN go build -ldflags "${COMPILE_FLAGS}" -o rp-archiver ./cmd/rp-archiver

FROM debian:buster AS rp-archiver
RUN adduser --uid 1000 --disabled-password --gecos '' --home /srv/rp-archiver rp-archiver
RUN apt-get -yq update \
        && DEBIAN_FRONTEND=noninteractive apt-get install -y \
                unattended-upgrades \
                ca-certificates \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get clean
COPY --from=builder /root/rp-archiver/rp-archiver /usr/bin/
USER rp-archiver
ENTRYPOINT ["rp-archiver"]
