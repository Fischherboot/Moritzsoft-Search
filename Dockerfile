FROM node:24-bookworm-slim AS themebuilder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/searxng/searxng.git /home/nomadx/searxng-custom

COPY . /app/searxng-moritzsoft

# Moritzsoft Less-Definitionen vor dem Build einspielen
RUN cp /app/searxng-moritzsoft/theme/moritzsoft/definitions.less \
      /home/nomadx/searxng-custom/client/simple/src/less/definitions.less

WORKDIR /home/nomadx/searxng-custom/client/simple

# Theme bauen (Node 24)
RUN npm install --no-audit --no-fund --ignore-scripts && \
    npx vite build


FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    python3 \
    python3-pip \
    python3-venv \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Gebauten SearXNG-Tree aus dem Builder übernehmen
COPY --from=themebuilder /home/nomadx/searxng-custom /home/nomadx/searxng-custom

# Dein Moritzsoft-Repo
COPY . /app/searxng-moritzsoft

# Bootstrap ausführen
RUN chmod +x /app/searxng-moritzsoft/scripts/bootstrap-docker.sh && \
    /app/searxng-moritzsoft/scripts/bootstrap-docker.sh

# Sicherstellen, dass die gebauten Theme-Dateien wirklich in die finale Installation wandern
RUN mkdir -p /opt/searxng-moritzsoft/searx/static/themes/simple && \
    cp -a /home/nomadx/searxng-custom/searx/static/themes/simple/. \
          /opt/searxng-moritzsoft/searx/static/themes/simple/

# Zusätzliche Moritzsoft-Assets / Overrides / Branding
RUN mkdir -p \
    /opt/searxng-moritzsoft/searx/static/themes/simple/css \
    /opt/searxng-moritzsoft/searx/static/themes/simple/js \
    /opt/searxng-moritzsoft/searx/static/themes/simple/img && \
    cp /app/searxng-moritzsoft/static/moritzsoft-override.css \
       /opt/searxng-moritzsoft/searx/static/themes/simple/css/ && \
    cp /app/searxng-moritzsoft/static/moritzsoft-particles.js \
       /opt/searxng-moritzsoft/searx/static/themes/simple/js/ && \
    cp /app/searxng-moritzsoft/assets/favicon.svg \
       /opt/searxng-moritzsoft/searx/static/themes/simple/img/ && \
    cp /app/searxng-moritzsoft/assets/empty_favicon.svg \
       /opt/searxng-moritzsoft/searx/static/themes/simple/img/ && \
    cp /app/searxng-moritzsoft/brand/searxng.svg \
       /opt/searxng-moritzsoft/searx/static/themes/simple/img/ && \
    cp /app/searxng-moritzsoft/assets/moritzsoft-logo.png \
       /opt/searxng-moritzsoft/searx/static/themes/simple/img/

# CSS/JS in base.html injizieren
RUN sed -i 's#</head>#<link rel="stylesheet" href="/static/themes/simple/css/moritzsoft-override.css">\n</head>#' \
    /opt/searxng-moritzsoft/searx/templates/simple/base.html && \
    sed -i 's#</body>#<script src="/static/themes/simple/js/moritzsoft-particles.js"></script>\n</body>#' \
    /opt/searxng-moritzsoft/searx/templates/simple/base.html

WORKDIR /opt/searxng-moritzsoft

EXPOSE 8855

CMD ["./venv/bin/python", "-m", "searx.webapp"]
