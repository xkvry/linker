include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-linker
PKG_VERSION:=1.9.0
PKG_RELEASE:=20250815

PKG_MAINTAINER:=xkvry  <18803249741@163..com>
PKG_CONFIG_DEPENDS:=

LUCI_TITLE:=linker
LUCI_DEPENDS:=+linker
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/linker/config/
/etc/linker/logs/
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
