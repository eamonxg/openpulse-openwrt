include $(TOPDIR)/rules.mk

PKG_NAME:=pulse-server
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/eamonxg/pulse.git
PKG_SOURCE_VERSION:=main
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=Pulse
PKG_LICENSE:=Apache-2.0
PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

MAKE_PATH:=apps/server
RUST_PKG_LOCKED:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/pulse-server
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Pulse router monitoring service
  DEPENDS:=$(RUST_ARCH_DEPENDS)
endef

define Package/pulse-server/description
  Router-side REST and SSE service for the Pulse mobile app.
endef

define Package/pulse-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/pulse-server $(1)/usr/bin/pulse-server
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/pulse-server $(1)/etc/config/pulse-server
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/pulse-server $(1)/etc/init.d/pulse-server
endef

$(eval $(call RustBinPackage,pulse-server))
$(eval $(call BuildPackage,pulse-server))
