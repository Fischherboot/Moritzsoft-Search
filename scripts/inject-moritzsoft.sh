#!/bin/bash
# Injects MoritzSoft custom CSS + JS into SearXNG templates
set -e

INSTALL_PATH="${1:-/opt/searxng-moritzsoft}"
BASE_TEMPLATE="$INSTALL_PATH/searx/templates/simple/base.html"
STATIC_DIR="$INSTALL_PATH/searx/static/themes/simple"

echo "Injecting MoritzSoft assets..."

# Copy static files
cp /app/searxng-moritzsoft/static/moritzsoft-override.css "$STATIC_DIR/css/moritzsoft-override.css"
cp /app/searxng-moritzsoft/static/moritzsoft-particles.js "$STATIC_DIR/js/moritzsoft-particles.js"

# Inject CSS link before </head>
if ! grep -q "moritzsoft-override.css" "$BASE_TEMPLATE" 2>/dev/null; then
    sed -i 's|</head>|<link rel="stylesheet" href="{{ url_for('\''static'\'', filename='\''themes/simple/css/moritzsoft-override.css'\'') }}">\n</head>|' "$BASE_TEMPLATE"
    echo "  Injected CSS into base.html"
fi

# Inject particle JS before </body>
if ! grep -q "moritzsoft-particles.js" "$BASE_TEMPLATE" 2>/dev/null; then
    sed -i 's|</body>|<script src="{{ url_for('\''static'\'', filename='\''themes/simple/js/moritzsoft-particles.js'\'') }}"></script>\n</body>|' "$BASE_TEMPLATE"
    echo "  Injected JS into base.html"
fi

# Also patch the index (home) template for custom branding
INDEX_TEMPLATE="$INSTALL_PATH/searx/templates/simple/index.html"
if [ -f "$INDEX_TEMPLATE" ]; then
    # Try to replace the logo img tag with custom text logo
    # SearXNG uses: <img ... class="logo" ...> or similar
    # We add a CSS-only approach so no template hacking needed for logo
    echo "  Index template found, CSS handles logo override"
fi

echo "MoritzSoft injection complete!"
