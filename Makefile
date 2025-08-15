include $(TOPDIR)/rules.mk

PKG_NAME:=linker
PKG_VERSION:=1.9.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/xkvry/linker/archive/refs/tags/v$(PKG_VERSION).tar.gz
PKG_HASH:=skip  # 建议从下载页面获取实际的SHA256哈希值

PKG_MAINTAINER:=xkvry 18803249741@163.com
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

# 依赖.NET 8运行时
PKG_BUILD_DEPENDS:=dotnet-sdk-8.0/host

include $(INCLUDE_DIR)/package.mk

define Package/linker
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Linker - 异地设备组网工具
  URL:=https://github.com/xkvry/linker
  DEPENDS:=+libstdcpp +libpthread +dotnet-runtime-8.0
  # 支持的架构
  SUPPORTED_ARCHES:=x86_64 arm aarch64 mips mipsel
endef

define Package/linker/description
  基于.NET 8开发的网络工具，实现异地设备像在同一局域网内一样便捷访问。
  支持P2P打洞、中继连接、虚拟网卡组网等功能。
endef

define Build/Configure
  # 无需额外配置
endef

define Build/Compile
  cd $(PKG_BUILD_DIR) && \
  dotnet publish src/Linker.Server -c Release -o $(PKG_BUILD_DIR)/bin \
    --framework net8.0 \
    --runtime $(if $(findstring x86_64,$(ARCH)),linux-x64, \
              $(if $(findstring arm,$(ARCH)),linux-arm, \
              $(if $(findstring aarch64,$(ARCH)),linux-arm64, \
              $(if $(findstring mipsel,$(ARCH)),linux-mipsel, \
              $(if $(findstring mips,$(ARCH)),linux-mips,linux-x64))))) \
    --self-contained false \
    -p:PublishTrimmed=true \
    -p:TrimMode=link
endef

define Package/linker/install
  # 安装二进制文件
  $(INSTALL_DIR) $(1)/usr/bin/linker
  $(CP) $(PKG_BUILD_DIR)/bin/* $(1)/usr/bin/linker/
  
  # 安装配置文件
  $(INSTALL_DIR) $(1)/etc/linker
  $(CP) $(PKG_BUILD_DIR)/src/Linker.Server/appsettings.json $(1)/etc/linker/
  
  # 安装启动脚本
  $(INSTALL_DIR) $(1)/etc/init.d
  $(INSTALL_BIN) ./files/linker.init $(1)/etc/init.d/linker
  
  # 安装防火墙配置
  $(INSTALL_DIR) $(1)/etc/firewall.d
  $(INSTALL_DATA) ./files/linker.firewall $(1)/etc/firewall.d/linker
endef

define Package/linker/postinst
#!/bin/sh
# 检查是否在第一次安装
if [ -z "$${IPKG_INSTROOT}" ]; then
  # 启用并启动服务
  /etc/init.d/linker enable
  /etc/init.d/linker start
fi
exit 0
endef

define Package/linker/prerm
#!/bin/sh
# 检查是否在卸载
if [ -z "$${IPKG_INSTROOT}" ]; then
  /etc/init.d/linker stop
  /etc/init.d/linker disable
fi
exit 0
endef

$(eval $(call BuildPackage,linker))
