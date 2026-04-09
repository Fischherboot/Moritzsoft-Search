# Maintainer: Moritz Nickel <moritz@onlymoritz.de>
pkgname=searxng-moritzsoft
_pkgname=searxng
pkgver=r9135.8bf600c
pkgrel=1
pkgdesc="SearXNG with moritzsoft.de theme and branding"
arch=('any')
url="https://github.com/Fischherboot/searxng-moritzsoft"
license=('AGPL3')
depends=('python' 'systemd')
makedepends=('openssl' 'git' 'python-virtualenv' 'npm' 'gcc' 'make' 'libvips' 'python' 'pkgconf')
optdepends=(
    'redis: Caching support'
    'valkey: Alternative caching'
)
provides=('searxng')
conflicts=('searx' 'searx-git' 'searxng' 'searxng-rama')
backup=('opt/searxng-moritzsoft/searx/settings.yml')
install=${pkgname}.install

_giturl="https://github.com/searxng/searxng"
_gitbranch="master"
source=(git+$_giturl#branch=$_gitbranch
        git+https://github.com/Fischherboot/searxng-moritzsoft.git)
b2sums=('SKIP' 'SKIP')

pkgver() {
  cd $_pkgname
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short=7 HEAD)"
}

build() {
  cd "$srcdir/$_pkgname"

  msg2 "Applying MoritzSoft theme..."
  cp "${srcdir}/searxng-moritzsoft/theme/moritzsoft/definitions.less" "client/simple/src/less/definitions.less"

  mkdir -p "client/simple/src/brand"

  # Minimal placeholder SVG for vite build
  cp "${srcdir}/searxng-moritzsoft/brand/searxng.svg" "client/simple/src/brand/searxng.svg"

  if [ -f "${srcdir}/searxng-moritzsoft/assets/favicon.svg" ]; then
    cp "${srcdir}/searxng-moritzsoft/assets/favicon.svg" "client/simple/src/brand/searxng-wordmark.svg"
  fi

  if [ -f "${srcdir}/searxng-moritzsoft/assets/empty_favicon.svg" ]; then
    mkdir -p "client/simple/src/svg"
    cp "${srcdir}/searxng-moritzsoft/assets/empty_favicon.svg" "client/simple/src/svg/empty_favicon.svg"
  fi

  msg2 "Building theme..."
  cd client/simple
  npm install --no-audit --no-fund --ignore-scripts
  npx vite build
  cd "$srcdir/$_pkgname"

  # Copy custom assets AFTER vite build
  if [ -f "${srcdir}/searxng-moritzsoft/assets/favicon.svg" ]; then
    cp "${srcdir}/searxng-moritzsoft/assets/favicon.svg" "searx/static/themes/simple/img/favicon.svg"
  fi

  if [ -f "${srcdir}/searxng-moritzsoft/assets/empty_favicon.svg" ]; then
    cp "${srcdir}/searxng-moritzsoft/assets/empty_favicon.svg" "searx/static/themes/simple/img/empty_favicon.svg"
  fi

  cat > searx/version_frozen.py << EOF
VERSION_STRING = "1.0.0-moritzsoft"
VERSION_TAG = "1.0.0-moritzsoft"
DOCKER_TAG = "1.0.0-moritzsoft"
GIT_URL = "${_giturl}"
GIT_BRANCH = "${_gitbranch}"
EOF
}

package() {
  cd "$srcdir/$_pkgname"

  install -dm755 "$pkgdir/opt/searxng-moritzsoft"
  cp -r searx "$pkgdir/opt/searxng-moritzsoft/"

  for dir in dockerfiles docs utils; do
    [ -d "$dir" ] && cp -r "$dir" "$pkgdir/opt/searxng-moritzsoft/"
  done

  for file in Makefile manage requirements.txt requirements-dev.txt setup.py babel.cfg; do
    [ -f "$file" ] && install -Dm644 "$file" "$pkgdir/opt/searxng-moritzsoft/$file"
  done

  [ -d ".git" ] && cp -r .git "$pkgdir/opt/searxng-moritzsoft/"

  msg2 "Configuring settings..."
  local settings_file="${pkgdir}/opt/searxng-moritzsoft/searx/settings.yml"
  local secret_key="$(openssl rand -hex 32)"

  sed -i "s/secret_key: \"ultrasecretkey\"/secret_key: \"${secret_key}\"/" "$settings_file"
  sed -i "s/port: 8888/port: 8855/" "$settings_file"
  sed -i 's/bind_address: "127.0.0.1"/bind_address: "0.0.0.0"/' "$settings_file"
  sed -i 's/instance_name: "SearXNG"/instance_name: "MoritzSoft Search"/' "$settings_file"

  msg2 "Creating Python venv..."
  export PIP_DISABLE_PIP_VERSION_CHECK=1
  export PYTHONDONTWRITEBYTECODE=1
  python -m venv "$pkgdir/opt/searxng-moritzsoft/venv"
  "$pkgdir/opt/searxng-moritzsoft/venv/bin/pip" install --upgrade pip wheel
  "$pkgdir/opt/searxng-moritzsoft/venv/bin/pip" install -r "${srcdir}/${_pkgname}/requirements.txt"

  find "$pkgdir/opt/searxng-moritzsoft/venv/bin" -type f -exec sed -i "s|${pkgdir}||g" {} +
  [ -f "$pkgdir/opt/searxng-moritzsoft/venv/pyvenv.cfg" ] && sed -i "s|${pkgdir}||g" "$pkgdir/opt/searxng-moritzsoft/venv/pyvenv.cfg"
  find "$pkgdir/opt/searxng-moritzsoft/venv" -type f -name "*.py[co]" -delete
  find "$pkgdir/opt/searxng-moritzsoft/venv" -type d -name "__pycache__" -delete

  install -dm755 "$pkgdir/usr/bin"
  cat > "$pkgdir/usr/bin/moritzsoft-search-run" << 'EOF'
#!/bin/bash
export SEARXNG_SETTINGS_PATH=/opt/searxng-moritzsoft/searx/settings.yml
cd /opt/searxng-moritzsoft
exec /opt/searxng-moritzsoft/venv/bin/python -m searx.webapp "$@"
EOF
  chmod +x "$pkgdir/usr/bin/moritzsoft-search-run"

  install -dm755 "${pkgdir}/etc/systemd/system"
  cat > "${pkgdir}/etc/systemd/system/moritzsoft-search.service" << 'EOF'
[Unit]
Description=MoritzSoft Search
After=network.target

[Service]
Type=simple
User=searxng
WorkingDirectory=/opt/searxng-moritzsoft
Environment="SEARXNG_SETTINGS_PATH=/opt/searxng-moritzsoft/searx/settings.yml"
ExecStart=/usr/bin/moritzsoft-search-run
Restart=on-failure
RestartSec=5
ReadWritePaths=/opt/searxng-moritzsoft

[Install]
WantedBy=multi-user.target
EOF

  install -Dm644 "${srcdir}/${_pkgname}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
