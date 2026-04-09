FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl git python3 python3-pip python3-venv openssl \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/searxng/searxng.git /home/nomadx/searxng-custom

COPY . /app/searxng-moritzsoft

# Apply Moritzsoft color definitions BEFORE vite build
RUN cp /app/searxng-moritzsoft/theme/moritzsoft/definitions.less \
       /home/nomadx/searxng-custom/client/simple/src/less/definitions.less

# Build theme with vite (compiles Less -> CSS)
RUN cd /home/nomadx/searxng-custom/client/simple && \
    npm install --no-audit --no-fund --ignore-scripts && \
    npx vite build

# Bootstrap: copy files, venv, config
RUN chmod +x /app/searxng-moritzsoft/scripts/bootstrap-docker.sh && \
    /app/searxng-moritzsoft/scripts/bootstrap-docker.sh

# Copy branding SVGs
RUN cp /app/searxng-moritzsoft/assets/favicon.svg /opt/searxng-moritzsoft/searx/static/themes/simple/img/favicon.svg && \
    cp /app/searxng-moritzsoft/assets/empty_favicon.svg /opt/searxng-moritzsoft/searx/static/themes/simple/img/empty_favicon.svg && \
    cp /app/searxng-moritzsoft/brand/searxng.svg /opt/searxng-moritzsoft/searx/static/themes/simple/img/searxng.svg

# Inject full Moritzsoft UI (CSS override + particle canvas JS)
RUN chmod +x /app/searxng-moritzsoft/scripts/inject-moritzsoft.sh && \
    /app/searxng-moritzsoft/scripts/inject-moritzsoft.sh /opt/searxng-moritzsoft

EXPOSE 8855

WORKDIR /opt/searxng-moritzsoft
CMD ["./venv/bin/python", "-m", "searx.webapp"]
