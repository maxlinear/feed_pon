#
# Copyright (c) 2025 MaxLinear Inc.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mxl862xx-dsa
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_PROJECT:=ethersw
PKG_SOURCE_NAME:=mxl862xx_dsa
CONFIG_UGW_PKG_SOURCE_URL:=https://github.com
PKG_SOURCE_URL:=$(CONFIG_UGW_PKG_SOURCE_URL)/$(PKG_PROJECT)/$(PKG_SOURCE_NAME).git
PKG_SOURCE_VERSION:=master
PKG_MIRROR_HASH:=be80298fc846a319caa5f1c8a404f8624092962b0087c2b6d155faa331e612d8
PKG_VERSION:=$(PKG_SOURCE_VERSION)
PKG_MAINTAINER:=MaxLinear
PKG_BUILD_PARALLEL:=OD1
PKG_IS_KERNEL_MODULE:=y
PKG_DEFAULT_CUSTOM_SOURCE_DIR:=$(TOPDIR)/../source/mxl862xx-dsa/
PKG_LICENSE:=GPL-2.0

-include $(INCLUDE_DIR)/package-version-override.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
  SUBMENU:=MaxLinear
  TITLE:=mxl862xx dsa driver
  URL:=https://www.maxlinear.com
  MAINTAINER:=MaxLinear
  DEPENDS:= @(TARGET_intel_mips_prx300||TARGET_intel_x86_lgm)
  KCONFIG:= \
	CONFIG_BRIDGE=y \
	CONFIG_NET_DSA=y \
	CONFIG_NET_DSA_TAG_MXL862=y \
	CONFIG_NET_DSA_TAG_MXL862_8021Q=y
  FILES:= \
	$(PKG_BUILD_DIR)/mxl862xx_dsa.ko \
	$(PKG_BUILD_DIR)/tag_mxl862xx.ko \
	$(PKG_BUILD_DIR)/tag_mxl862xx_8021q.ko 
  AUTOLOAD:=$(call AutoLoad,06,mxl862xx_dsa tag_mxl862xx tag_mxl862xx_8021q)
  MENU:=1
endef

define KernelPackage/$(PKG_NAME)/description
  mxl862xx Linux DSA driver
endef

define KernelPackage/$(PKG_NAME)/config
  $(call Package/kmod-$(PKG_NAME)/override_version)
  $(call Package/kmod-$(PKG_NAME)/override_source_path)
  menu "configuration"
  depends on PACKAGE_kmod-mxl862xx-dsa
  config PACKAGE_kmod-mxl862xx-dsa_DEBUG
		bool "enable debug logging"
		depends on KERNEL_NET_DSA
		help
		  This will enable debug logging in the dsa driver
  endmenu
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(LINUX_KARCH)" \
		BSP_KERNEL_DIR=$(LINUX_DIR) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="-I$(LINUX_DIR)/net/dsa" \
		modules
endef

define Build/InstallDev
endef

define Build/Clean
	if [ -d $(PKG_BUILD_DIR) ]; then \
		$(MAKE) -C $(PKG_BUILD_DIR) KERNEL_DIR=$(LINUX_DIR) clean; \
		$(RM) -r $(PKG_BUILD_DIR)/ipkg-$(BOARD); \
	fi
endef

$(eval $(call KernelPackage,$(PKG_NAME)))

