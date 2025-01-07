#
# Copyright (C) 2020 - 2023 MaxLinear, Inc.
# Copyright (c) 2019 Intel Corporation
# Copyright (c) 2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pon-tod
PKG_VERSION:=1.4.1
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_PROTO:=git
PKG_PROJECT:=mxl-oss/pon
PKG_SOURCE_NAME:=pon_tod
CONFIG_UGW_PKG_SOURCE_URL:=ssh://git@git.maxlinear.com
PKG_SOURCE_URL:=$(CONFIG_UGW_PKG_SOURCE_URL)/$(PKG_PROJECT)/$(PKG_SOURCE_NAME).git
PKG_MIRROR_HASH:=2ba123fc4cf37a9c8d8fd08f6e4adc2a687ae62b65297001fad9579b2d8db20b
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_BIN_DIR=usr/bin
PKG_INSTALL:=1
PKG_ASLR_PIE_REGULAR:=1
PKG_LICENSE:=MaxLinear Commercial Use License
PKG_LICENSE_FILES:=LICENSE

-include $(INCLUDE_DIR)/package-version-override.mk
include $(INCLUDE_DIR)/package.mk

# avoid build directly in the source directories
PKG_AUTOMAKE_PATHS:=.
CONFIGURE_PATH=build_$(PKGARCH)
CONFIGURE_CMD=../configure
MAKE_PATH=$(CONFIGURE_PATH)
PKG_INSTALL_DIR=$(PKG_BUILD_DIR)/$(CONFIGURE_PATH)/ipkg-install
# update stamps with CONFIGURE_PATH
STAMP_CONFIGURED=$(PKG_BUILD_DIR)/$(CONFIGURE_PATH)/.configured$(if $(DUMP),,_$(call confvar,$(PKG_CONFIG_DEPENDS)))
STAMP_CONFIGURED_WILDCARD=$(PKG_BUILD_DIR)/$(CONFIGURE_PATH)/.configured_*
STAMP_BUILT=$(PKG_BUILD_DIR)/$(CONFIGURE_PATH)/.built

define Package/$(PKG_NAME)
  SECTION:=application
  CATEGORY:=MaxLinear
  TITLE:= PON Time of Day Daemon
  URL:=https://www.maxlinear.com
  MAINTAINER:=MaxLinear
  MENU:=1
  SUBMENU:=PON
  DEPENDS:= +!USE_GLIBC:argp-standalone-shared +@BUSYBOX_CONFIG_STTY \
	+libsafec3-7
endef

define Package/$(PKG_NAME)/description
	PON ToD Daemon
endef

define Package/$(PKG_NAME)/config
	menu "configuration"
	depends on PACKAGE_$(PKG_NAME)

	config PACKAGE_$(PKG_NAME)_ENABLE_DEBUG
		bool "enable debug support (e.g. error logging)"
		help
			This will enable debug prints and support for a logfile.
	endmenu
	$(call Package/$(PKG_NAME)/override_source_path)
endef

# make the submake silent:
ifeq ($(QUIET),1)
MAKE_FLAGS+=-s
endif
ifneq (,$(findstring 99,$(V)))
MAKE_FLAGS+=-s
endif

TARGET_CFLAGS += -Werror

#include path for safec 3.7
TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/safeclib

CONFIGURE_ARGS += \
	$(call autoconf_bool,CONFIG_PACKAGE_$(PKG_NAME)_ENABLE_DEBUG,debug)

define Build/Configure
	mkdir -p $(PKG_BUILD_DIR)/$(CONFIGURE_PATH)
	$(call Build/Configure/Default)
endef

define Build/Clean
	@- rm -Rf $(PKG_BUILD_DIR)/ipkg*
	@- [ -e $(PKG_BUILD_DIR)/$(MAKE_PATH)/Makefile ] && $(MAKE) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) clean
	@- rm -Rf $(PKG_BUILD_DIR)/$(CONFIGURE_PATH)
	$(call Build/Clean/Default)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/$(PKG_BIN_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/todd $(1)/$(PKG_BIN_DIR)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/todd.init $(1)/etc/init.d/todd

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/todd.uci-defaults $(1)/etc/uci-defaults/todd
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
