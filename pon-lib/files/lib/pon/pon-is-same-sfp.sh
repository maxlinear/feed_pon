#!/bin/sh
# shellcheck shell=dash
#
# Copyright (c) 2025 Maxlinear Inc.

# pon-is-same-sfp.sh
#
# This script checks whether the PON (Passive Optical Network) port is using
# the same SFP (Small Form-factor Pluggable) module as expected.
# It returns 0 if the SFP matches, or a non-zero value otherwise.
#
# Usage: ./pon-is-same-sfp.sh

same_sfp() {
    local optic_transceiver

    . /lib/pon/pondb.sh

    # not in pon mode, driver not active?
    [ -e "$EEPROM_PATH" ] || return 255

    optic_transceiver=$(uci -q get optic.common.transceiver_name)
    [ "$optic_transceiver" != "$transceiver_name" ] && return 1

    return 0
}

same_sfp
status=$?

[ "$DEBUG" ] && echo "Same SFP? -> $status"

return $status
