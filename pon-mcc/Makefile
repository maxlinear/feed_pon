#
# Copyright (c) 2022-2023 MaxLinear, Inc.
# Copyright (c) 2019 Intel Corporation
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pon-mcc
PKG_VERSION:=0.0.0
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_PROTO:=git
PKG_PROJECT:=mxl-oss/pon
PKG_SOURCE_NAME:=pon_mcc
CONFIG_UGW_PKG_SOURCE_URL:=ssh://git@git.maxlinear.com
PKG_SOURCE_URL:=$(CONFIG_UGW_PKG_SOURCE_URL)/$(PKG_PROJECT)/$(PKG_SOURCE_NAME).git
PKG_MIRROR_HASH:=78512b64290151e2c7b428f9ecd9376f27552f7ce05653f53270386c0aa4f49c
PKG_RELEASE:=1
PKG_BUILD_PARALLEL:=1
PKG_BIN_DIR=usr/bin
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_LICENSE:=MaxLinear
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
  TITLE:= PON Multicast Daemon
  URL:=https://www.maxlinear.com
  MAINTAINER:=MaxLinear
  MENU:=1
  SUBMENU:=PON
  DEPENDS:= +libubus +libubox \
	+libsafec3-7
endef

define Package/$(PKG_NAME)/description
	PON Multicast Daemon
endef

# make the submake silent:
ifeq ($(QUIET),1)
MAKE_FLAGS+=-s
endif
ifneq (,$(findstring 99,$(V)))
MAKE_FLAGS+=-s
endif

#include path for safec 3.7
TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/safeclib

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
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pon_mcc $(1)/$(PKG_BIN_DIR)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mcc.init $(1)/etc/init.d/mcc
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
