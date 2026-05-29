#!/usr/bin/env bash
#
# Build the OpenWrt (musl) openpulse-server binaries from the openpulse source
# repo and replace the prebuilt binaries in this feed's openpulse-server/bins/.
#
# Produces 6 binaries from 3 Rust targets (the 4 aarch64 variants differ only
# by -C target-cpu):
#   x86_64-unknown-linux-musl        -> bins/x86_64
#   armv7-unknown-linux-musleabihf   -> bins/armv7-baseline
#   aarch64-unknown-linux-musl       -> bins/aarch64-generic
#     + target-cpu=cortex-a53/a72/a76-> bins/aarch64-cortex-a53/a72/a76
#
# Prerequisites (one-time):
#   rustup target add x86_64-unknown-linux-musl \
#                     armv7-unknown-linux-musleabihf \
#                     aarch64-unknown-linux-musl
#   brew install zig
#   cargo install cargo-zigbuild
#
# Usage:
#   scripts/build-bins.sh [path-to-openpulse-source]
# The openpulse source repo defaults to the sibling ../openpulse (override via
# the first argument or the OPENPULSE_SRC env var).
#
# This script only builds + replaces binaries. Committing, tagging and pushing
# the release are deliberately left as manual steps (see README "Updating
# binaries").

set -euo pipefail

export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:$PATH"

# This feed repo (where bins/ lives).
FEED_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BINS="$FEED_ROOT/openpulse-server/bins"

# openpulse source repo: arg 1 > $OPENPULSE_SRC > sibling ../openpulse.
SRC="${1:-${OPENPULSE_SRC:-$(cd "$FEED_ROOT/.." && pwd)/openpulse}}"
SERVER_DIR="$SRC/apps/server"
TARGET="$SERVER_DIR/target"

# --- sanity checks ---------------------------------------------------------
command -v zig >/dev/null            || { echo "error: zig not found (brew install zig)" >&2; exit 1; }
cargo zigbuild --help >/dev/null 2>&1 || { echo "error: cargo-zigbuild not found (cargo install cargo-zigbuild)" >&2; exit 1; }
[ -d "$SERVER_DIR/crates/openpulse-server" ] || { echo "error: server source not found at $SERVER_DIR" >&2; exit 1; }
[ -d "$BINS" ]                        || { echo "error: bins dir not found at $BINS" >&2; exit 1; }

echo "==> server source : $SERVER_DIR"
echo "==> output bins   : $BINS"

cd "$SERVER_DIR"

build() { # build <rust-target> [target-cpu]
  local target="$1" cpu="${2:-}"
  if [ -n "$cpu" ]; then
    echo "==> building $target (target-cpu=$cpu)"
    RUSTFLAGS="-C target-cpu=$cpu" cargo zigbuild --release --target "$target" -p openpulse-server
  else
    echo "==> building $target"
    cargo zigbuild --release --target "$target" -p openpulse-server
  fi
}

place() { # place <rust-target> <bins-subdir>
  install -m644 "$TARGET/$1/release/openpulse-server" "$BINS/$2/openpulse-server"
  echo "    -> bins/$2"
}

# x86_64
build x86_64-unknown-linux-musl
place x86_64-unknown-linux-musl x86_64

# armv7
build armv7-unknown-linux-musleabihf
place armv7-unknown-linux-musleabihf armv7-baseline

# aarch64 generic + per-CPU variants (each RUSTFLAGS change recompiles)
build aarch64-unknown-linux-musl
place aarch64-unknown-linux-musl aarch64-generic
for cpu in cortex-a53 cortex-a72 cortex-a76; do
  build aarch64-unknown-linux-musl "$cpu"
  place aarch64-unknown-linux-musl "aarch64-$cpu"
done

echo ""
echo "==> done. updated binaries:"
for d in x86_64 armv7-baseline aarch64-generic aarch64-cortex-a53 aarch64-cortex-a72 aarch64-cortex-a76; do
  printf "    %-20s " "$d"
  file "$BINS/$d/openpulse-server" | grep -oE "ARM aarch64|ARM, EABI5|x86-64" || echo "?"
done

echo ""
echo "Next (manual):"
echo "  cd $FEED_ROOT"
echo "  git add openpulse-server/bins && git commit -m 'chore: update prebuilt binaries to vX.Y.Z'"
echo "  git push origin main"
echo "  # re-tag a release:"
echo "  git tag -d vX.Y.Z; git push origin :refs/tags/vX.Y.Z"
echo "  git tag -a vX.Y.Z -m 'openpulse-server vX.Y.Z' && git push origin vX.Y.Z"
