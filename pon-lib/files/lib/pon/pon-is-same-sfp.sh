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
    local optic_transceiver pon_mode

    . /lib/pon/pondb.sh

    # not in pon mode, driver not active?
    [ -e "$EEPROM_PATH" ] || return 255

    pon_mode=$(uci -q get gpon.ponip.pon_mode)
    case "$pon_mode" in
    "" | "Undefined")
        # if the pon mode is not know, try to detect again, maybe the SFP was just plugged in
        check_optic_change
        # try to start omcid, will check for new pon mode on its own
        if /etc/init.d/omcid.sh enabled; then
            /etc/init.d/omcid.sh boot
        fi
        ;;
    esac

    optic_transceiver=$(uci -q get optic.common.transceiver_name)
    [ "$optic_transceiver" != "$TRANSCEIVER_NAME" ] && return 1

    return 0
}

same_sfp
status=$?

[ "$DEBUG" ] && echo "Same SFP? -> $status"

exit $status
