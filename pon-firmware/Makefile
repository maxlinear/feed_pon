#
# Copyright (C) 2022-2023 MaxLinear, Inc.
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pon-firmware
PKG_SOURCE_PROTO:=git
PKG_PROJECT:=maxlinear
PKG_SOURCE_NAME:=pon_firmware_binary
CONFIG_UGW_PKG_SOURCE_URL:=ssh://git@github.com
PKG_SOURCE_URL:=$(CONFIG_UGW_PKG_SOURCE_URL)/$(PKG_PROJECT)/$(PKG_SOURCE_NAME).git
PKG_SOURCE_VERSION:=4.1.x.y.8
PKG_VERSION:=$(PKG_SOURCE_VERSION)
PKG_MIRROR_HASH:=adb2fc3e64f7f96bf8428c2549e78e7a963a4e82b93903d62129cd09c7dd69cd

PKG_LICENSE:=MAXLINEAR PROPRIETARY SOFTWARE LICENSE AGREEMENT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=MaxLinear

include $(INCLUDE_DIR)/package.mk

define Package/pon-firmware/Default
  CATEGORY:=MaxLinear
  SUBMENU:=PON
  URL:=https://www.maxlinear.com
endef

define Package/pon-xpon-firmware-b
$(call Package/pon-firmware/Default)
  TITLE:=PON IP firmware for XGSPON, XGPON and NGPON2 type B
endef

define Package/pon-gpon-firmware-b
$(call Package/pon-firmware/Default)
  TITLE:=PON IP firmware for GPON type B
endef

define Package/pon-xpon-firmware-urx-b
$(call Package/pon-firmware/Default)
  TITLE:=PON IP FW for XGSPON, XGPON, NGPON2 URX type B
endef

define Package/pon-gpon-firmware-urx-b
$(call Package/pon-firmware/Default)
  TITLE:=PON IP firmware for GPON URX type B
endef

define Package/pon-xpon-firmware-urx-c
$(call Package/pon-firmware/Default)
  TITLE:=PON IP FW for XGSPON, XGPON, NGPON2 URX type C
endef

define Package/pon-gpon-firmware-urx-c
$(call Package/pon-firmware/Default)
  TITLE:=PON IP firmware for GPON URX type C
endef


define Build/Compile
endef

define Package/pon-xpon-firmware-b/install
	$(INSTALL_DIR) $(1)/lib/firmware/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ponip_g989_prx/binary.bin $(1)/lib/firmware/prx_xpon_fw_b.bin
endef

define Package/pon-gpon-firmware-b/install
	$(INSTALL_DIR) $(1)/lib/firmware/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ponip_g984_prx/binary.bin $(1)/lib/firmware/prx_gpon_fw_b.bin
endef

define Package/pon-xpon-firmware-urx-b/install
	$(INSTALL_DIR) $(1)/lib/firmware/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ponip_g989_urx/binary.bin $(1)/lib/firmware/urx_xpon_fw_b.bin
endef

define Package/pon-gpon-firmware-urx-b/install
	$(INSTALL_DIR) $(1)/lib/firmware/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ponip_g984_urx/binary.bin $(1)/lib/firmware/urx_gpon_fw_b.bin
endef

define Package/pon-xpon-firmware-urx-c/install
	$(INSTALL_DIR) $(1)/lib/firmware/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ponip_g989_urx_c/binary.bin $(1)/lib/firmware/urx_xpon_fw_c.bin
endef

define Package/pon-gpon-firmware-urx-c/install
	$(INSTALL_DIR) $(1)/lib/firmware/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ponip_g984_urx_c/binary.bin $(1)/lib/firmware/urx_gpon_fw_c.bin
endef

$(eval $(call BuildPackage,pon-xpon-firmware-b))
$(eval $(call BuildPackage,pon-gpon-firmware-b))
$(eval $(call BuildPackage,pon-xpon-firmware-urx-b))
$(eval $(call BuildPackage,pon-gpon-firmware-urx-b))
$(eval $(call BuildPackage,pon-xpon-firmware-urx-c))
$(eval $(call BuildPackage,pon-gpon-firmware-urx-c))
