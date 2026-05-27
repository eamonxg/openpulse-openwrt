include $(TOPDIR)/rules.mk

PKG_NAME:=openpulse-server
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/eamonxg/openpulse.git
PKG_SOURCE_VERSION:=main
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=OpenPulse
PKG_LICENSE:=Apache-2.0
PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

MAKE_PATH:=apps/server
RUST_PKG_LOCKED:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/openpulse-server
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenPulse router monitoring service
  DEPENDS:=$(RUST_ARCH_DEPENDS)
endef

define Package/openpulse-server/description
  Router-side REST and SSE service for OpenPulse Mobile.
endef

define Package/openpulse-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/openpulse-server $(1)/usr/bin/openpulse-server
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/openpulse $(1)/etc/config/openpulse
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/openpulse $(1)/etc/init.d/openpulse
endef

$(eval $(call RustBinPackage,openpulse-server))
$(eval $(call BuildPackage,openpulse-server))
