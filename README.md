# openpulse-openwrt

OpenWrt package feed and release builder for OpenPulse Server.

## Packages

- `openpulse-server` - Rust HTTP service for OpenPulse Mobile.

## Build With OpenWrt SDK

Add this repository as a custom feed, then install and compile the package:

```sh
echo "src-git openpulse_openwrt https://github.com/eamonxg/openpulse-openwrt.git" >> feeds.conf.default
./scripts/feeds update openpulse_openwrt
./scripts/feeds install openpulse-server
make package/openpulse-server/compile V=s
```

For local development, override `PKG_SOURCE_URL` and `PKG_SOURCE_VERSION` in
`openpulse-server/Makefile` or build from a release tag in the upstream `openpulse`
repository.
