# MoritzSoft Search Dockerfile
# SearXNG with moritzsoft.de styling

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl git python3 python3-pip python3-venv openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/nomadx/searxng-custom

COPY . /app/searxng-moritzsoft

RUN if [ ! -d "/home/nomadx/searxng-custom/searx" ]; then \
        git clone https://github.com/searxng/searxng.git /home/nomadx/searxng-custom; \
    fi

RUN chmod +x /app/searxng-moritzsoft/scripts/bootstrap-docker.sh && \
    /app/searxng-moritzsoft/scripts/bootstrap-docker.sh

RUN test -d /opt/searxng-moritzsoft && \
    test -f /opt/searxng-moritzsoft/searx/settings.yml

EXPOSE 8855

WORKDIR /opt/searxng-moritzsoft
CMD ["./venv/bin/python", "-m", "searx.webapp"]
