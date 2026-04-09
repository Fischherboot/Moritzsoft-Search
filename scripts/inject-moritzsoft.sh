#!/bin/bash
# Injects MoritzSoft custom UI into SearXNG templates
# Replaces particles.js with full UI injection (nav, footer, logo, particles)
set -e

INSTALL_PATH="${1:-/opt/searxng-moritzsoft}"
BASE_TEMPLATE="$INSTALL_PATH/searx/templates/simple/base.html"
STATIC_DIR="$INSTALL_PATH/searx/static/themes/simple"

echo "Injecting MoritzSoft UI..."

# Copy static files
cp /app/searxng-moritzsoft/static/moritzsoft-override.css "$STATIC_DIR/css/moritzsoft-override.css"
cp /app/searxng-moritzsoft/static/moritzsoft-ui.js "$STATIC_DIR/js/moritzsoft-ui.js"

# Copy logo PNG
if [ -f "/app/searxng-moritzsoft/assets/moritzsoft-logo.png" ]; then
    cp /app/searxng-moritzsoft/assets/moritzsoft-logo.png "$STATIC_DIR/img/moritzsoft-logo.png"
    echo "  Copied logo PNG"
fi

# Inject CSS link before </head>
if ! grep -q "moritzsoft-override.css" "$BASE_TEMPLATE" 2>/dev/null; then
    sed -i 's|</head>|<link rel="stylesheet" href="{{ url_for('\''static'\'', filename='\''themes/simple/css/moritzsoft-override.css'\'') }}">\n</head>|' "$BASE_TEMPLATE"
    echo "  Injected CSS into base.html"
fi

# Remove old particles.js injection if present
sed -i '/moritzsoft-particles.js/d' "$BASE_TEMPLATE"

# Inject moritzsoft-ui.js before </body>
if ! grep -q "moritzsoft-ui.js" "$BASE_TEMPLATE" 2>/dev/null; then
    sed -i 's|</body>|<script src="{{ url_for('\''static'\'', filename='\''themes/simple/js/moritzsoft-ui.js'\'') }}"></script>\n</body>|' "$BASE_TEMPLATE"
    echo "  Injected UI JS into base.html"
fi

echo "MoritzSoft UI injection complete!"
