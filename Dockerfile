FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    bash \
    curl \
    wget \
    python3 \
    python3-pip \
    jq \
    wireguard-tools \
    iproute2 \
    iptables \
    procps \
    ca-certificates \
    socat \
    miniupnpc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
