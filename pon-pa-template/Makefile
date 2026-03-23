#
# Copyright (c) 2025 MaxLinear, Inc.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pon-pa-template
PKG_VERSION:=0.0.3
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_PROTO:=git
PKG_PROJECT:=maxlinear
PKG_SOURCE_NAME:=pon_pa_template
CONFIG_UGW_PKG_SOURCE_URL:=https://github.com
PKG_SOURCE_URL:=$(CONFIG_UGW_PKG_SOURCE_URL)/$(PKG_PROJECT)/$(PKG_SOURCE_NAME).git
PKG_MIRROR_HASH:=573d823a487d0a27fc94725340c6c29ebe2aadad55e7be8b6f59950e9a892a1f
PKG_RELEASE:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_LICENSE:=BSD-2-Clause
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
  TITLE:= PON PA Template
  URL:=https://www.maxlinear.com
  MAINTAINER:=MaxLinear
  MENU:=1
  SUBMENU:=PON
  DEPENDS:=+pon-adapter
endef

define Package/$(PKG_NAME)/description
 PON Image Library
endef

# make the submake silent:
ifeq ($(QUIET),1)
MAKE_FLAGS+=-s
endif
ifneq (,$(findstring 99,$(V)))
MAKE_FLAGS+=-s
endif

CONFIGURE_ARGS += \
	--enable-pon-adapter-include="-I$(STAGING_DIR)/usr/include/pon_adapter" \
	--enable-pon-adapter-library="-L$(STAGING_DIR)/usr/lib"

TARGET_CFLAGS += -Werror

define Build/Configure
	mkdir -p $(PKG_BUILD_DIR)/$(CONFIGURE_PATH)
	$(call Build/Configure/Default)
endef

define Build/Clean
	@- [ -e $(PKG_BUILD_DIR)/$(MAKE_PATH)/Makefile ] && $(MAKE) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) clean
	@- rm -Rf $(PKG_BUILD_DIR)/$(CONFIGURE_PATH)
	$(call Build/Clean/Default)
endef

define Build/InstallDev_
	$(INSTALL_DIR) $(1)/usr/include/pon_img
	$(CP) $(PKG_BUILD_DIR)/include/*.h $(1)/usr/include/pon_img
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpatemplate.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/omci-pa-template $(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
