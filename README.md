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

This feed contains a Makefile that wraps a **pre-built binary** produced by
the OpenPulse CI. To build a `.ipk` locally:

1. Build the Rust binary using `cross` from the [`openpulse`](https://github.com/eamonxg/openpulse) repo:
   ```bash
   cd openpulse/apps/server
   cross build --release --target aarch64-unknown-linux-musl
   ```
2. Copy the binary into this feed's `openpulse-server/prebuilt-bin/`:
   ```bash
   mkdir -p openpulse-server/prebuilt-bin
   cp openpulse/apps/server/target/aarch64-unknown-linux-musl/release/openpulse-server \
      openpulse-server/prebuilt-bin/
   ```
3. Use the OpenWrt SDK (Docker image or local install) with this directory as a feed and run:
   ```bash
   make package/openpulse-server/compile V=s
   ```

The same `cross build` command is what CI runs in stage 1 — local and CI
binaries are byte-identical given the same `RUSTFLAGS` and source commit.

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

The workflow in `.github/workflows/build.yml` runs in two stages:

**Stage 1 (`build-rust`)** — 6 jobs, each running `cross build --release` for
one binary variant. Produces artifacts named `openpulse-binary-<binary_id>`.

**Stage 2 (`build-openwrt-package`)** — 28 jobs (14 platforms × 2 OpenWrt
releases). Each job downloads the matching binary artifact from stage 1 and
invokes `openwrt/gh-action-sdk` to produce a `.ipk`. No Rust compilation
happens in this stage.

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
