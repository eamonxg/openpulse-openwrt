include $(TOPDIR)/rules.mk

PKG_NAME:=openpulse-server
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenPulse
PKG_LICENSE:=Apache-2.0

# No source download, no compilation. Binary is pre-built by CI stage 1
# (cross-rs) and placed in $(CURDIR)/prebuilt-bin/openpulse-server before
# this Makefile runs. See .github/workflows/build.yml stage 2.
PKG_BUILD_DEPENDS:=
PKG_BUILD_PARALLEL:=0
PKG_FLAGS:=nonshared

# Tell OpenWrt the package directory itself is the "source" — we do not need
# anything from the network.
PKG_SOURCE:=

PREBUILT_BIN := $(CURDIR)/prebuilt-bin/openpulse-server

include $(INCLUDE_DIR)/package.mk

define Package/openpulse-server
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenPulse router monitoring service
  URL:=https://github.com/eamonxg/openpulse
  DEPENDS:=
endef

define Package/openpulse-server/description
  Router-side REST and SSE service for OpenPulse Mobile.
  This package contains a pre-built statically-linked binary produced by
  the OpenPulse CI pipeline. The OpenWrt SDK only wraps it into .ipk; no
  Rust compilation happens inside the SDK build.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	test -f $(PREBUILT_BIN) || { \
		echo "ERROR: prebuilt binary not found at $(PREBUILT_BIN)"; \
		echo "Stage 1 of the CI workflow must place it there before invoking the SDK."; \
		exit 1; \
	}
	cp $(PREBUILT_BIN) $(PKG_BUILD_DIR)/openpulse-server
	chmod +x $(PKG_BUILD_DIR)/openpulse-server
endef

define Build/Configure
endef

define Build/Compile
	# Pre-built; nothing to compile.
endef

define Package/openpulse-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openpulse-server $(1)/usr/bin/openpulse-server
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/openpulse $(1)/etc/config/openpulse
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/openpulse $(1)/etc/init.d/openpulse
endef

$(eval $(call BuildPackage,openpulse-server))
