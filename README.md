# openpulse-openwrt

OpenWrt package feed and release builder for **OpenPulse Server**.

This repository packages the router-side OpenPulse service for OpenWrt. The
product source code lives in the sibling repository:

```text
openpulse             # OpenPulse Server + OpenPulse Mobile + shared API types
openpulse-openwrt     # OpenWrt package definition, SDK builds, release artifacts
```

## What This Builds

| Name | Purpose |
|------|---------|
| `openpulse-server` | OpenWrt package name and Rust binary |
| `openpulse` | OpenWrt `procd` service name and UCI config name |

The package installs:

```text
/usr/bin/openpulse-server
/etc/init.d/openpulse
/etc/config/openpulse
```

After installation, OpenPulse Server listens on the LAN address at port `6688`
by default and exposes the REST/WebSocket API consumed by OpenPulse Mobile.

## Package Contents

```text
openpulse-server/
  Makefile
  files/
    etc/
      config/openpulse
      init.d/openpulse
```

The Makefile expects a pre-built statically-linked binary at
`openpulse-server/prebuilt-bin/openpulse-server` before the SDK runs.
The CI pipeline places it there automatically; see the GitHub Actions section
below.

## Supported Architectures

OpenPulse ships statically-linked musl binaries for the following 14 OpenWrt
architectures, produced by CI from 3 Rust target triples:

| Rust target                         | OpenWrt platforms |
|-------------------------------------|-------------------|
| `aarch64-unknown-linux-musl`        | `aarch64_generic`, `aarch64_cortex-a53`, `aarch64_cortex-a72`, `aarch64_cortex-a76` |
| `x86_64-unknown-linux-musl`         | `x86_64` |
| `armv7-unknown-linux-musleabihf`    | `arm_cortex-a7`, `arm_cortex-a7_vfpv4`, `arm_cortex-a7_neon-vfpv4`, `arm_cortex-a5_vfpv4`, `arm_cortex-a8_vfpv3`, `arm_cortex-a9`, `arm_cortex-a9_vfpv3-d16`, `arm_cortex-a9_neon`, `arm_cortex-a15_neon-vfpv4` |

### Explicitly unsupported

- All `mips_*` / `mipsel_*` platforms (Rust dropped tier-2 support in 1.72; removed from rustup in 1.78).
- Pre-ARMv7 chips (`arm_arm926ej-s`, `arm_fa526`, `arm_xscale`, `arm_arm1176jzf-s_vfp`).
- `riscv64_riscv64` — buildable, but no consumer router uses it; can be added on demand.

### Building locally

Pre-built binaries are committed in `openpulse-server/bins/<binary_id>/openpulse-server`.
To build a `.ipk` locally, copy the desired binary to the staging directory and
invoke the SDK:

```bash
mkdir -p openpulse-server/prebuilt-bin
cp openpulse-server/bins/aarch64-generic/openpulse-server \
   openpulse-server/prebuilt-bin/openpulse-server
make package/openpulse-server/compile V=s
```

### Updating binaries

When a new server version is ready, rebuild and commit the binaries:

```bash
# From the openpulse server source directory
export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:$PATH"

cargo zigbuild --release --target x86_64-unknown-linux-musl -p openpulse-server
cargo zigbuild --release --target armv7-unknown-linux-musleabihf -p openpulse-server
cargo zigbuild --release --target aarch64-unknown-linux-musl -p openpulse-server

BINS=<path-to-openpulse-openwrt>/openpulse-server/bins
TARGET=apps/server/target

cp $TARGET/x86_64-unknown-linux-musl/release/openpulse-server      $BINS/x86_64/
cp $TARGET/armv7-unknown-linux-musleabihf/release/openpulse-server  $BINS/armv7-baseline/
cp $TARGET/aarch64-unknown-linux-musl/release/openpulse-server      $BINS/aarch64-generic/

RUSTFLAGS="-C target-cpu=cortex-a53" cargo zigbuild --release --target aarch64-unknown-linux-musl -p openpulse-server
cp $TARGET/aarch64-unknown-linux-musl/release/openpulse-server      $BINS/aarch64-cortex-a53/

RUSTFLAGS="-C target-cpu=cortex-a72" cargo zigbuild --release --target aarch64-unknown-linux-musl -p openpulse-server
cp $TARGET/aarch64-unknown-linux-musl/release/openpulse-server      $BINS/aarch64-cortex-a72/

RUSTFLAGS="-C target-cpu=cortex-a76" cargo zigbuild --release --target aarch64-unknown-linux-musl -p openpulse-server
cp $TARGET/aarch64-unknown-linux-musl/release/openpulse-server      $BINS/aarch64-cortex-a76/

# Then commit in openpulse-openwrt:
git add openpulse-server/bins/
git commit -m "chore: update prebuilt binaries to vX.Y.Z"
```

## Runtime Configuration

The service is managed by OpenWrt `procd`:

```sh
service openpulse start
service openpulse restart
service openpulse stop
```

Configuration is stored in UCI:

```sh
uci show openpulse
uci get openpulse.config.token
uci set openpulse.config.port='6688'
uci commit openpulse
service openpulse restart
```

If `openpulse.config.token` is empty on first start, the init script generates a
token and writes it to UCI. OpenPulse Mobile uses this token as a Bearer token:

```text
Authorization: Bearer <token>
```

## GitHub Actions

The workflow in `.github/workflows/build.yml` has a single stage:
**`build-openwrt-package`** — 28 jobs (14 platforms × 2 OpenWrt releases).
Each job checks out this repo (which includes the pre-built binaries in
`bins/`), copies the correct binary to `prebuilt-bin/`, then invokes
`openwrt/gh-action-sdk` to produce a `.ipk`. No Rust compilation happens in CI.

On tag pushes matching `v*`, the `release` job attaches all 28 `.ipk` files to
a GitHub Release.

## Naming

The naming boundary is intentional:

```text
OpenPulse              # product brand
OpenPulse Mobile       # mobile app
OpenPulse Server       # router-side service
openpulse              # main source repository
openpulse-openwrt      # OpenWrt package/release repository
openpulse-server       # OpenWrt package and installed binary
openpulse              # OpenWrt service and UCI config
```
