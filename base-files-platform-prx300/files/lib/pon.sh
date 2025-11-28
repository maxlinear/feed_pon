#!/bin/sh
# shellcheck shell=dash
# shellcheck disable=SC3060
#
# Copyright (C) 2011 OpenWrt.org
# Copyright (C) 2011 lantiq.com
# Copyright (C) 2018 - 2020 Intel Corporation
# Copyright (c) 2022 - 2025 Maxlinear Inc.

pon_dt_name() {
	local machine
	local name

	# use cpuinfo
	machine=$(awk 'BEGIN{FS="[ \t]+:[ \t]"} /machine/ {print $2}' /proc/cpuinfo)

	[ -z "$machine" ] && {
		# or directly the device tree
		[ -e /proc/device-tree/model ] && machine=$(cat /proc/device-tree/model)
	}

	# use first word in lower case
	name=$(echo $machine | awk '{print tolower($1);}')

	echo "$name"
}

pon_board_name() {
	local name

	# take board name from cmdline
	name=$(awk 'BEGIN{RS=" ";FS="="} /boardname/ {print $2}' /proc/cmdline)
	# or use devicetree as fallback
	[ -z "$name" ] && name=$(pon_dt_name)

	echo "$name"
}

# return only the board identification, without variadic parts
# like memory sizes, wan mode or addon modules
pon_board_base_name() {
	local name
	name=$(pon_board_name)
	# remove parts of the names
	name=${name/-w5500/}
	name=${name/-10g-lan/}
	name=${name/-b48/}
	name=${name/-256/}
	name=${name/-512/}
	name=${name/-1gb-ddr4/}
	name=${name/-eth/}
	name=${name/-pon/}
	echo "$name"
}

# return ponmbox node status
pon_mbox_node_status() {
	local node
	local node_paths="/proc/device-tree/ssx1_1@18000000/"
	local status=""

	for path in $node_paths; do
		node=$(ls -d "$path"ponmbox*) 2> /dev/null
		[ -n "$node" ] && [ -e "$node/status" ] && {
			status=$(cat "$node/status")
			break
		}
	done

	echo "$status"
}

# return the (board specific) number of lan ports
pon_get_number_of_lan_ports() {
	local num="1"

	case $(pon_board_name) in
	prx300* | prx126* | prx120*)
		num="1"
		;;
	prx321*)
		num="2"
		;;
	esac

	echo $num
}

# return the (board specific) default interface used for "lct"
pon_default_lct_get() {
	case $(pon_board_name) in
	prx300* | prx321* | prx126* | prx120*)
		echo "eth0_0_1_lct"
		;;
	*)
		echo "eth0_0"
		;;
	esac
}

pon_lct_num_get() {
	local ifname=$(uci -q get network.lct.ifname)
	local uni_num=$(uci -q get network.lct.uni_num)
	if [ -n "$uni_num" ]; then
		echo "`expr $uni_num \\- 1`"
		return
	fi
	case ${ifname} in
	eth0_*)
		ifname=${ifname#eth0_}
		ifname=${ifname%_1_lct}
		echo "${ifname}"
		return
		;;
	esac
}

pon_sgmii_mode() {
	local retval="6" # 6 = 10G
	# TODO: Extend to define other speed modes
	echo $retval
}

pon_base_mac_get() {
	local mac_addr=$(awk 'BEGIN{RS=" ";FS="="} $1 == "ethaddr" {print $2}' /proc/cmdline)
	[ -z "$mac_addr" ] && mac_addr='ac:9a:96:00:00:00'
	echo $mac_addr
}

_hex2mac() {
	# adding ":" after each 2 chars and remove the last one again
	echo $1 | sed -e 's/../&:/g' -e 's/:$//'
}

_mac_add_offset() {
	local mac=$1
	local offs=$(printf "%d\n" $2) # make sure this is decimal

	mac=$(echo "$mac" | tr -d ':') # to remove colons
	mac=$(printf "%d\n" 0x$mac)    # to convert to decimal
	mac=$(expr $mac + $offs)       # add offset
	mac=$(printf "%012x\n" $mac)   # to convert to hex again

	echo $(_hex2mac $mac)
}

pon_mac_get() {
	local mac_offset
	local mac_limit=6

	case "$1" in
	eth0_0_1_lct | eth0_1_1_lct | lct)
		mac_offset=0
		;;
	host | wan | eth1)
		mac_offset=1
		;;
	eth0_0 | eth0_0_[23])
		# subifs 2/3 are for MC/BC and can use same mac as main ifc
		mac_offset=2
		;;
	eth0_1 | eth0_1_[23])
		# subifs 2/3 are for MC/BC and can use same mac as main ifc
		mac_offset=3
		;;
	iphost)
		mac_offset=$((4+$2))
		;;
	*)
		mac_offset=-1
		;;
	esac

	if [ $mac_offset -ge 0 ]; then
		echo $(_mac_add_offset $(pon_base_mac_get) $mac_offset)
	fi

	if [ "$mac_offset" -ge "$mac_limit" ]; then
		echo "pon.sh[warning]: used mac_offset($mac_offset) over the limit($mac_limit)" >&2
	fi
}

pon_oui_get() {
	echo $(pon_base_mac_get) | awk 'BEGIN{FS=":"} {printf "%s:%s:%s\n", $1,$2,$3}'
}

pon_is_10g_platform() {
	# true
	return 0
}
