# MoritzSoft Search

SearXNG fork mit dem moritzsoft.de Design. Basiert auf [searxng-RAMA](https://github.com/Nomadcxx/searxng-RAMA).

## Features

- moritzsoft.de Farbschema (#08080a Background, #8c52ff Purple, #ff914d Orange)
- Glassmorphism-inspirierte UI
- Inter Font
- Datenschutz-Link auf rechtliches.moritzsoft.de
- Deutsche Locale als Default
- Port 8855

## Quick Start (Docker)

```bash
docker-compose up -d
```

Dann erreichbar unter http://localhost:8855

## Manuell bauen

```bash
git clone https://github.com/Fischherboot/searxng-moritzsoft.git
cd searxng-moritzsoft
docker build -t moritzsoft-search .
docker run -d -p 8855:8855 moritzsoft-search
```

## Dateien

| Datei | Was es tut |
|-------|------------|
| `theme/moritzsoft/definitions.less` | Alle Farben/CSS-Variablen im moritzsoft.de Style |
| `brand/searxng.svg` | Logo: Moritz(grau)Soft(gradient) Search(grau) |
| `assets/favicon.svg` | Lila Lupe als Favicon |
| `searxng-moritzsoft-settings.yml` | Settings mit moritzsoft Branding |
| `scripts/bootstrap-docker.sh` | Docker-Bootstrap |

## Links

- [moritzsoft.de](https://moritzsoft.de)
- [Rechtliches & Impressum](https://rechtliches.moritzsoft.de)

## Lizenz

AGPL-3.0 (SearXNG) + MSOL (Moritzsoft Branding)
