#!/bin/bash
# Docker bootstrap script for MoritzSoft Search (SearXNG fork)
set -e

echo "Bootstrapping MoritzSoft Search..."

INSTALL_PATH="/opt/searxng-moritzsoft"
SOURCE_PATH="/home/nomadx/searxng-custom"
VENV_PATH="$INSTALL_PATH/venv"

mkdir -p "$INSTALL_PATH"

echo "Copying SearXNG files..."
cp -r "$SOURCE_PATH/searx" "$INSTALL_PATH/"
cp -r "$SOURCE_PATH/dockerfiles" "$INSTALL_PATH/" 2>/dev/null || true
cp -r "$SOURCE_PATH/docs" "$INSTALL_PATH/" 2>/dev/null || true
cp -r "$SOURCE_PATH/utils" "$INSTALL_PATH/" 2>/dev/null || true

for file in Makefile manage requirements.txt requirements-dev.txt setup.py babel.cfg .git; do
  [ -e "$SOURCE_PATH/$file" ] && cp -r "$SOURCE_PATH/$file" "$INSTALL_PATH/"
done

echo "Setting up Python venv..."
cd "$INSTALL_PATH"
python3 -m venv "$VENV_PATH"
"$VENV_PATH/bin/pip" install -r requirements.txt

echo "Configuring settings..."
SETTINGS_PATH="$INSTALL_PATH/searx/settings.yml"

if [ -f "$SETTINGS_PATH" ]; then
  SECRET_KEY=$(openssl rand -hex 32)
  sed -i "s/secret_key: \"ultrasecretkey\"/secret_key: \"$SECRET_KEY\"/g" "$SETTINGS_PATH"
  sed -i "s/port: 8888/port: 8855/g" "$SETTINGS_PATH"
  sed -i 's/bind_address: "127.0.0.1"/bind_address: "0.0.0.0"/g' "$SETTINGS_PATH"
  sed -i 's/instance_name: "SearXNG"/instance_name: "MoritzSoft Search"/g' "$SETTINGS_PATH"
  sed -i "s/image_proxy: false/image_proxy: true/g" "$SETTINGS_PATH"
  sed -i "s/limiter: true/limiter: false/g" "$SETTINGS_PATH"

  # Set privacy policy URL
  if grep -q "privacypolicy_url:" "$SETTINGS_PATH"; then
    sed -i 's|privacypolicy_url:.*|privacypolicy_url: https://rechtliches.moritzsoft.de|g' "$SETTINGS_PATH"
  fi

  # Center alignment
  if grep -q "center_alignment:" "$SETTINGS_PATH"; then
    sed -i "s/center_alignment: .*/center_alignment: true/g" "$SETTINGS_PATH"
  else
    sed -i "/ui:/a\  center_alignment: true" "$SETTINGS_PATH"
  fi
else
  SECRET_KEY=$(openssl rand -hex 32)
  cat > "$SETTINGS_PATH" << EOF
use_default_settings: true

server:
  secret_key: "$SECRET_KEY"
  limiter: false
  image_proxy: true
  port: 8855
  bind_address: "0.0.0.0"

general:
  debug: false
  instance_name: "MoritzSoft Search"
  privacypolicy_url: https://rechtliches.moritzsoft.de

ui:
  default_theme: simple
  center_alignment: true
  default_locale: de
EOF
fi

echo "Applying MoritzSoft theme..."

# Copy definitions.less (the core theme file that changes all colors)
cp /app/searxng-moritzsoft/theme/moritzsoft/definitions.less "$INSTALL_PATH/searx/static/themes/simple/less/" 2>/dev/null || true

# Copy branding
if [ -f "/app/searxng-moritzsoft/brand/searxng.svg" ]; then
  cp /app/searxng-moritzsoft/brand/searxng.svg "$INSTALL_PATH/searx/static/themes/simple/img/searxng.svg" 2>/dev/null || true
fi

if [ -f "/app/searxng-moritzsoft/assets/favicon.svg" ]; then
  cp /app/searxng-moritzsoft/assets/favicon.svg "$INSTALL_PATH/searx/static/themes/simple/img/favicon.svg"
fi

if [ -f "/app/searxng-moritzsoft/assets/empty_favicon.svg" ]; then
  cp /app/searxng-moritzsoft/assets/empty_favicon.svg "$INSTALL_PATH/searx/static/themes/simple/img/empty_favicon.svg"
fi

echo "Bootstrap complete!"
echo "Installation: $INSTALL_PATH"
echo "Run: $VENV_PATH/bin/python -m searx.webapp"
