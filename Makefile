include $(TOPIR)/rules.mk

# 基础包信息（必选）
PKG_NAME:=linker                  # 包名称，必须与目录名一致
PKG_VERSION:=1.9.0                    # 源码版本号
PKG_RELEASE:=1                        # 包发布号，每次修改包时递增
PKG_LICENSE:=GPL-2.0                  # 许可证类型
PKG_LICENSE_FILES:=LICENSE            # 许可证文件路径
#PKG_MAINTAINER:=Your Name <your@email.com>  # 维护者信息

# 从Git仓库获取
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/xkvry/linker.git  # 源码仓库地址
PKG_SOURCE_VERSION:=master  # 特定commit哈希或分支名（如master）
PKG_MIRROR_HASH:=skip                    # 可选，源码校验值（自动生成：make package/helloworld/update）

# 依赖设置（可选）
PKG_BUILD_DEPENDS:=+libuci +libubus +autoconf +automake +libtool +pkg-config +gcc +g++ +make +python +perl +libopenssl     # 编译时依赖（仅编译阶段需要）
# PKG_BUILD_PARALLEL:=1                 # 允许并行编译（适合多文件项目）

# 目标架构设置（可选）
# PKG_ARCH:=all                         # 所有架构通用
# PKG_ARCH:=x86_64 arm aarch64          # 指定支持的架构

# 引入OpenWRT基础包定义（必选）
include $(INCLUDE_DIR)/package.mk

# 定义包元数据（必选）
define Package/$(PKG_NAME)
  SECTION:=net                        # 一级分类（net/utils/libs/system等）
  CATEGORY:=network                   # 二级分类（menuconfig中显示的菜单名）
  SUBMENU:=My Custom Packages           # 三级子菜单（可选）
  TITLE:=linker            # 包显示名称
  URL:=https://github.com/xkvry/linker  # 项目主页
  DEPENDS:=+zlib +bash +iptables +kmod-tun +ip-full +kmod-ipt-nat +libstdcpp +libopenssl +libopenssl-legacy             # 运行时依赖（目标系统必须安装的包）
endef

# 包详细描述（可选）
define Package/$(PKG_NAME)/description
  linker
endef

# 编译前配置（可选，根据构建系统选择）
# define Build/Configure
  # Autotools项目示例
#   (cd $(PKG_BUILD_DIR); \
#     ./autogen.sh; \
#     ./configure \
#       --prefix=/usr \
#       --host=$(GNU_HOST_NAME) \
#       --build=$(GNU_BUILD_NAME) \
#       --disable-static \
#       --enable-shared \
#   );

  # CMake项目示例（注释掉上面的Autotools部分，使用下面的）
  # mkdir -p $(PKG_BUILD_DIR)/build
  # (cd $(PKG_BUILD_DIR)/build; \
  #   cmake .. \
  #     -DCMAKE_INSTALL_PREFIX=/usr \
  #     -DCMAKE_C_COMPILER=$(TARGET_CC) \
  #     -DCMAKE_CXX_COMPILER=$(TARGET_CXX) \
  #     -DCMAKE_C_FLAGS="$(TARGET_CFLAGS)" \
  #     -DCMAKE_LDFLAGS="$(TARGET_LDFLAGS)" \
  # );
# endef

# 编译命令（必选，根据构建系统修改）
define Build/Compile
  # Make项目示例
  $(MAKE) -C $(PKG_BUILD_DIR) \
    CC="$(TARGET_CC)" \
    CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
    LDFLAGS="$(TARGET_LDFLAGS)" \
    all

  # CMake项目示例（配合上面的CMake配置）
  # $(MAKE) -C $(PKG_BUILD_DIR)/build
endef

# 安装到目标系统（必选）
define Package/$(PKG_NAME)/install
  # 创建目标目录
  $(INSTALL_DIR) $(1)/usr/bin          # 可执行文件目录
  $(INSTALL_DIR) $(1)/etc/config       # 配置文件目录（可选）
  $(INSTALL_DIR) $(1)/etc/init.d       # 启动脚本目录（可选）

  # 安装可执行文件
  $(INSTALL_BIN) $(PKG_BUILD_DIR)/src/linker $(1)/usr/bin/

  # 安装配置文件（可选）
  $(INSTALL_CONF) ./files/linker.config $(1)/etc/config/linker

  # 安装启动脚本（可选，需设置可执行权限）
  $(INSTALL_BIN) ./files/linker.init $(1)/etc/init.d/linker
endef

# 可选：添加启动脚本启用配置（如果有启动脚本）
define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
  # 启用服务（与/etc/init.d/下的脚本名一致）
  /etc/init.d/linker enable
  exit 0
}
endef

# 可选：卸载时清理（如果需要）
define Package/$(PKG_NAME)/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
  # 停止服务
  /etc/init.d/linker disable
  /etc/init.d/linker stop
  exit 0
}
endef

# 生成包（必选）
$(eval $(call BuildPackage,$(PKG_NAME)))
