#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
dockerfile="${repo_root}/src/Dockerfile"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[ -f "${dockerfile}" ] || fail "missing src/Dockerfile"

if grep -Eq 'php8\.[0-4]|php-[a-z]' "${dockerfile}"; then
  fail "web-builder must not install older distro/default PHP packages; Jenkins composer install requires PHP 8.5"
fi

grep -Eq 'php8\.5-cli|php:8\.5|PHP_VERSION=8\.5' "${dockerfile}" \
  || fail "web-builder Dockerfile should explicitly provide PHP 8.5 CLI"

grep -Eq 'php8\.5-xml|docker-php-ext-install.*xml|PHP.*xml' "${dockerfile}" \
  || fail "web-builder should provide PHP XML support for composer/Jekyll tooling"

echo "web-builder image config checks passed"
