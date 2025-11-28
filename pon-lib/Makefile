#
# Copyright (C) 2020 - 2023 MaxLinear, Inc.
# Copyright (C) 2019 Intel Corporation
# Copyright (C) 2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pon-lib
PKG_VERSION:=2.3.4
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_PROTO:=git
PKG_PROJECT:=maxlinear
PKG_SOURCE_NAME:=pon_lib
CONFIG_UGW_PKG_SOURCE_URL:=https://github.com
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.xz
PKG_SOURCE_URL:=$(CONFIG_UGW_PKG_SOURCE_URL)/$(PKG_PROJECT)/$(PKG_SOURCE_NAME).git
PKG_MIRROR_HASH:=0f24e92e743a4393c6caf108160be1fe279192228b2987287242205cb18a7097
PKG_RELEASE:=1
PKG_BUILD_DEPENDS:=pon-mbox-drv
PKG_BIN_DIR=usr/bin
LIB_POSTFIX:=
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_ASLR_PIE_REGULAR:=1
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
  TITLE:= PON LIBRARY
  URL:=https://www.maxlinear.com
  MAINTAINER:=MaxLinear
  MENU:=1
  SUBMENU:=PON
  DEPENDS:=+pon-libnl-genl \
	+PON_ADAPTER_BUILD:ifxos \
	+@PON_ADAPTER_BUILD:IFXOS_SHARED_LIB \
	+PON_ADAPTER_BUILD:pon-adapter \
	+@BUSYBOX_CONFIG_HEXDUMP \
	+libsafec3-7
endef

define Package/$(PKG_NAME)-cli
  SECTION:=application
  CATEGORY:=MaxLinear
  TITLE:= PON LIBRARY CLI
  URL:=https://www.maxlinear.com
  MAINTAINER:=MaxLinear
  SUBMENU:=PON
  DEPENDS:=+$(PKG_NAME) +lib-cli
endef

define Package/$(PKG_NAME)-daemon
  SECTION:=application
  CATEGORY:=MaxLinear
  TITLE:= PON LIBRARY DAEMON
  URL:=https://www.maxlinear.com
  MAINTAINER:=MaxLinear
  SUBMENU:=PON
  DEPENDS:=+$(PKG_NAME) +libubus
endef

define Package/$(PKG_NAME)/description
	PON library
endef

define Package/ponmbox-cli
  SUBMENU:=PON
  CATEGORY:=MaxLinear
  TITLE:=PON mailbox cli tool
  DEPENDS:=+kmod-pon-mbox-drv +libnl-genl \
	+libsafec3-7
endef

define Package/$(PKG_NAME)/config
	menu "configuration"
	depends on PACKAGE_$(PKG_NAME)
	config PON_ADAPTER_BUILD
		bool "enable build with PON Adapter"
		default y
		help
			This will enable build with PON Adapter in the pon_lib.
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

CONFIGURE_ARGS += \
	--enable-libnl-include="-I$(STAGING_DIR)/usr/include/pon-libnl3" \
	--enable-libnl-library="-L$(STAGING_DIR)/opt/pon/lib" \
	--enable-cli-include="-I$(STAGING_DIR)/usr/include/cli" \
	--enable-cli-library="-L$(STAGING_DIR)/usr/lib" \
	--enable-mboxdrv-include="-I$(STAGING_DIR)/usr/include/pon" \
	--enable-pon-adapter-include="-I$(STAGING_DIR)/usr/include/pon_adapter" \
	--enable-pon-adapter-library="-L$(STAGING_DIR)/usr/lib" \
	$(call autoconf_bool,CONFIG_PON_ADAPTER_BUILD,pon-adapter)

TARGET_CFLAGS += -Werror

#include path for safec 3.7
TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/safeclib

define Build/Configure
	mkdir -p $(PKG_BUILD_DIR)/$(CONFIGURE_PATH)
	$(call Build/Configure/Default)
endef

define Build/Clean
	@- [ -e $(PKG_BUILD_DIR)/$(MAKE_PATH)/Makefile ] && $(MAKE) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) clean
	@- rm -Rf $(PKG_BUILD_DIR)/$(CONFIGURE_PATH)
	$(call Build/Clean/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/pon_lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/pon_lib/*.h $(1)/usr/include/pon_lib/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpon.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpon_cli.a $(1)/usr/lib
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpon.so* $(1)/usr/lib
endef

define Package/$(PKG_NAME)-cli/install
	$(INSTALL_DIR) $(1)/$(PKG_BIN_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pon $(1)/$(PKG_BIN_DIR)
endef

define Package/$(PKG_NAME)-daemon/install
	$(INSTALL_DIR) $(1)/$(PKG_BIN_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pond $(1)/$(PKG_BIN_DIR)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files-daemon/pond $(1)/etc/init.d/
endef

define Package/ponmbox-cli/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ponmbox $(1)/usr/bin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-cli))
$(eval $(call BuildPackage,$(PKG_NAME)-daemon))
$(eval $(call BuildPackage,ponmbox-cli))
