#!/usr/bin/env bash

set -e

PREFIX="${PREFIX:-$HOME/.local}"
BIN="$PREFIX/bin"

mkdir -p "$BIN"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$SCRIPT_DIR/aghil" "$BIN/aghil"
chmod +x "$BIN/aghil"

SHELL_RC="$HOME/.bashrc"

if [ -n "${PREFIX:-}" ] && [[ "$PREFIX" == *"com.termux"* ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

if ! grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
fi

export PATH="$HOME/.local/bin:$PATH"

echo
echo "╔══════════════════════════════════════╗"
echo "║   🚀 AGHIL TERMINAL HELPER V2       ║"
echo "║          نصب با موفقیت               ║"
echo "╚══════════════════════════════════════╝"
echo
echo "اجرا:"
echo
echo "    aghil"
echo
