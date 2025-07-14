#
# Copyright (C) 2020 - 2023 MaxLinear, Inc.
# Copyright (c) 2017 - 2020 Intel Corporation
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=pon-kernel

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define KernelPackage/dp-eth-reinsert/description
 MaxLinear Kernel module for PON Ethernet reinsertion support.
endef

define KernelPackage/dp-eth-reinsert
  SUBMENU:=MaxLinear
  TITLE:= PON Ethernet reinsertion support
  DEPENDS:=@(TARGET_intel_x86_lgm||TARGET_intel_mips_prx300) +kmod-gwdpa-dpm +kmod-qos-tc
  KCONFIG:=CONFIG_DP_ETH_REINSERT
  FILES:=$(LINUX_DIR)/drivers/net/datapath/dp_eth_reinsert/dp_eth_reinsert.ko
  AUTOLOAD:=$(call AutoLoad,15,dp_eth_reinsert)
endef

define KernelPackage/pon-arp-ndp-reinsert
  TITLE:=PON multicast packet bridge reinsert
  SUBMENU:=MaxLinear
  DEPENDS:=+kmod-nft-bridge
  KCONFIG:=CONFIG_DP_ARP_NDP_REINSERT
  FILES:=$(LINUX_DIR)/drivers/net/datapath/bridge_filter/arp_ndp_reinsert.ko
  # We do not want to load this in all models and do this manually in the pon_net_lib when the LCT was created.
  # AUTOLOAD:=$(call AutoProbe,arp_ndp_reinsert)
endef

define KernelPackage/pon-mcc-drv-filter
  TITLE:=PON multicast filter driver
  SUBMENU:=MaxLinear
  DEPENDS:=+kmod-nft-bridge
  KCONFIG:=CONFIG_DP_MCAST_BRIDGE_FILTER
  FILES:=$(LINUX_DIR)/drivers/net/datapath/bridge_filter/mcast_bridge_filter.ko
  AUTOLOAD:=$(call AutoProbe,mcast_bridge_filter)
endef

define Build/Configure
endef

define Build/Compile
endef

$(eval $(call KernelPackage,dp-eth-reinsert))
$(eval $(call KernelPackage,pon-arp-ndp-reinsert))
$(eval $(call KernelPackage,pon-mcc-drv-filter))
