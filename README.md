# pulse-openwrt-feed

OpenWrt package feed for Pulse router-side services.

## Packages

- `pulse-server` - Rust HTTP service for the Pulse mobile app.

## Build With OpenWrt SDK

Add this repository as a custom feed, then install and compile the package:

```sh
echo "src-git pulse_openwrt https://github.com/eamonxg/pulse-openwrt-feed.git" >> feeds.conf.default
./scripts/feeds update pulse_openwrt
./scripts/feeds install pulse-server
make package/pulse-server/compile V=s
```

For local development, override `PKG_SOURCE_URL` and `PKG_SOURCE_VERSION` in
`pulse-server/Makefile` or build from a release tag once the upstream `pulse`
repository URL is finalized.
