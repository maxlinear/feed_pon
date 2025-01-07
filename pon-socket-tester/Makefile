#
# Copyright (c) 2020 - 2023 MaxLinear, Inc.
# Copyright (c) 2020 Intel Corporation
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pon-socket-tester
PKG_VERSION:=1.0.0

PKG_SOURCE_PROTO:=git
PKG_PROJECT:=mxl-oss/pon
PKG_SOURCE_NAME:=pon_socket_tester
CONFIG_UGW_PKG_SOURCE_URL:=ssh://git@git.maxlinear.com
PKG_SOURCE_URL:=$(CONFIG_UGW_PKG_SOURCE_URL)/$(PKG_PROJECT)/$(PKG_SOURCE_NAME).git
PKG_SOURCE_VERSION:=c23b8658a84ed780786734ecb7b76b41ec0eddfa
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_MIRROR_HASH:=bac50a9202de0bca32dc383108ddf2ef45cfcd2fb5554f0b2a7c0585c7355828

PKG_BUILD_PARALLEL:=1
PKG_BIN_DIR=usr/bin
PKG_INSTALL:=1
PKG_LICENSE:=MaxLinear
PKG_LICENSE_FILES:=LICENSE
PKG_FIXUP:=autoreconf

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
  SUBMENU:=PON
  CATEGORY:=MaxLinear
  TITLE:=PON raw socket testing application
  URL:=https://www.maxlinear.com
  MAINTAINER:=MaxLinear
endef

define Package/$(PKG_NAME)/description
	This package contains application to check if kernel network driver
	is robust against incorrect message sending via a raw socket interface
endef

# make the submake silent:
ifeq ($(QUIET),1)
MAKE_FLAGS+=-s
endif
ifneq (,$(findstring 99,$(V)))
MAKE_FLAGS+=-s
endif

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
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pon_socket_tester $(1)/$(PKG_BIN_DIR)
	$(INSTALL_BIN) ./files/pon-socket-tester.sh $(1)/$(PKG_BIN_DIR)
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/pon-sock-test.msg $(1)/etc
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
