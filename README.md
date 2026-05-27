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

`openpulse-server/Makefile` fetches the Rust source from:

```text
https://github.com/eamonxg/openpulse.git
```

The build currently tracks `main` via `PKG_SOURCE_VERSION:=main`. For
reproducible releases, pin this to a Git tag or commit SHA and update
`PKG_MIRROR_HASH`.

## Build With OpenWrt SDK

Inside an OpenWrt SDK checkout, add this repository as a custom feed:

```sh
echo "src-git openpulse_openwrt https://github.com/eamonxg/openpulse-openwrt.git" >> feeds.conf.default
./scripts/feeds update openpulse_openwrt
./scripts/feeds install openpulse-server
```

Compile the package:

```sh
make package/openpulse-server/compile V=s
```

The resulting `.ipk` or `.apk` artifacts are written under the SDK `bin/`
directory for the selected target.

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

## Local Development

For local package testing, edit `openpulse-server/Makefile`:

```make
PKG_SOURCE_URL:=https://github.com/eamonxg/openpulse.git
PKG_SOURCE_VERSION:=main
```

Common options:

| Goal | Change |
|------|--------|
| Build from a branch | Set `PKG_SOURCE_VERSION` to the branch name |
| Build from a commit | Set `PKG_SOURCE_VERSION` to the commit SHA |
| Build from a release | Set `PKG_SOURCE_VERSION` to the release tag |
| Reproducible build | Replace `PKG_MIRROR_HASH:=skip` with the real hash |

## GitHub Actions

The workflow in `.github/workflows/build.yml` builds `openpulse-server` across
multiple OpenWrt releases and target architectures using `openwrt/gh-action-sdk`.

On tag pushes matching `v*`, the workflow uploads package artifacts to the
GitHub Release.

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
