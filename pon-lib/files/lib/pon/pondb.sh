#!/bin/sh
# shellcheck shell=dash
# shellcheck disable=SC2155
#
# Copyright (C) 2019 - 2020 Intel Corporation
# Copyright (c) 2021 - 2025 Maxlinear Inc.

# all UPPERCASE variables are global and expected to be set also when sourcing
# this file into other script or current shell

OPTIC_DB_LOCATION="/etc/optic-db"
SERDES_DB_LOCATION="/etc/serdes-db"

. /lib/pon.sh

log_console() {
    echo "$@" > /dev/console
}

to_lower() {
    #tr on busybox doesn't support classes like [[:upper:]],
    #so this is done by awk
    awk '{print tolower($0)}'
}

normalize() {
    #The sed will throw out characters not suitable for filenames
    #(including whitespace)
    to_lower | sed -r 's/[^A-Za-z0-9_-]//g'
}

normalize_revision() {
    #same as normalize but will keep the '.' (dot)
    sed -r 's/[^A-Za-z0-9._-]//g'
}

hexbytes() {
    hexdump -ve '1/1 "%.2x"'
}

prepend() {
    local prefix="$1"
    shift || return
    sed "s,^,$prefix,"
}

append() {
    local suffix="$1"
    shift || return
    sed "s,$,$suffix,"
}

image_version_get() {
    # prefer the PON version, but if it is not there use the URDK version
    if [ -f /etc/pon.ver ]; then
        IMAGE_VERSION=$(cat /etc/pon.ver)
    elif [ -f /etc/version ]; then
        IMAGE_VERSION=$(cat /etc/version)
    else
        IMAGE_VERSION=""
    fi
}

read_eeprom_real_count() {
    local skip="$1"
    shift || return
    local count="$1"
    shift || return

    dd iflag=skip_bytes,count_bytes if="$EEPROM_PATH" skip="$skip" count="$count" 2> /dev/null
}

read_eeprom_bs1() {
    local skip="$1"
    shift || return
    local count="$1"
    shift || return

    dd bs=1 if="$EEPROM_PATH" skip="$skip" count="$count" 2> /dev/null
}

transceiver_names_get() {
    local vendor_name="$($READ_EEPROM 20 16 | normalize)"
    local vendor_oui="$($READ_EEPROM 37 3 | hexbytes)"
    local part_number="$($READ_EEPROM 40 16 | normalize)"
    local revision="$($READ_EEPROM 56 4 | normalize_revision)"

    #Examples:
    #wtd-001cad-rtsm166-501-1.0
    #wtd-rtxm166-501

    if [ -n "$vendor_name" ] && [ -n "$part_number" ]; then
        if [ "$vendor_oui" != "000000" ] && [ -n "$revision" ]; then
            echo "$vendor_name-$vendor_oui-$part_number-$revision"
        fi
        if [ -n "$revision" ]; then
            echo "$vendor_name-$part_number-$revision"
        fi
        if [ "$vendor_oui" != "000000"  ]; then
            echo "$vendor_name-$vendor_oui-$part_number"
        fi
        echo "$vendor_name-$part_number"
    fi
}

optic_files_get() {
    local board="$1"

    if [ -n "$board" ]; then
        # prepend directory name and append board name
        #Example: /etc/optic-db/superxonltd-sogx2699-psga-urx851-eva
        transceiver_names_get | prepend "$OPTIC_DB_LOCATION/" | append "-$board"
    fi

    #We prepend directory name
    #Example: /etc/optic-db/wtd-001cad-rtsm166-501-1.0
    transceiver_names_get | prepend "$OPTIC_DB_LOCATION/"
}

serdes_files_get() {
    local board="$1"

    if [ -n "$board" ]; then
        #We prepend directory name
        #Example: /etc/serdes-db/prx126-sfp-eva-pon-001cad-rtsm166-501-1.0.conf
        transceiver_names_get | prepend "$SERDES_DB_LOCATION/$board-" | append ".conf"
        echo "$SERDES_DB_LOCATION/$board.conf"
    fi
    echo "$SERDES_DB_LOCATION/default.conf"
}

uci_import() {
    local config="$1"
    local config_file="$2"

    uci -m import "$config" < "$config_file" &&
        log_console "[${config}-db] Applied '$config_file' configuration"
}

config_apply() {
    local config_file=""
    local config="$1"
    shift || return

    for filename in "$@"; do
        log_console "[${config}-db] Looking for '$filename' configuration"
        if [ -f "$filename" ]; then
            config_file="$filename"
            break
        fi
    done

    if [ -n "$config_file" ]; then
        uci_import "$config" "$config_file"
    fi
}

find_optic_mode() {
    local optic_mode=$(uci -q get optic.common.mode)
    local br_hex br_real
    local id_plus_connector transceiver_codes

    if [ -n "$optic_mode" ]; then
        # already available in config
        # exit early to avoid unnecessary eeprom read and parsing in case of already detected mode
        echo "$optic_mode"
        return
    fi

    # needs detection from sfp eeprom
    id_plus_connector="$($READ_EEPROM 0 3 | hexbytes)"
    # log_console "Id and connector (HEX): '$id_plus_connector'"
    case "$id_plus_connector" in
        "030401") # SFP with SC connector
            ;;
        "030407") # SFP with LC connector
            transceiver_codes="$($READ_EEPROM 3 7 | hexbytes)"
            # log_console "Transceiver Codes (HEX): '$transceiver_codes'"
            case "$transceiver_codes" in
                "00000000000000") # no bits for Ethernet of FiberChannel modes set
                    ;;
                *)
                    echo "Undefined"
                    return
                    ;;
            esac
            ;;
        *)
            echo "Undefined"
            return
            ;;
    esac

    br_hex="$($READ_EEPROM 12 1 | hexbytes)"
    if [ -n "$br_hex" ] && echo "$br_hex" | grep -Eq '^[0-9a-fA-F]+$'; then
        br_real=$(printf "%d" "$((0x${br_hex} * 100))")
        if [ "$br_real" -gt 9000 ]; then
            optic_mode="xgspon"
        elif [ "$br_real" -le 2500 ]; then
            optic_mode="gpon"
        else
            log_console "pon mode not detectable from nominal bitrate $br_real"
            optic_mode="Undefined"
        fi
    else
        log_console "Invalid or empty br_hex value: '$br_hex'"
        optic_mode="Undefined"
    fi

    echo "$optic_mode"
}

update_ponmode() {
    local optic_mode=$(find_optic_mode)
    local pon_mode=$(uci -q get gpon.ponip.pon_mode)

    # log_console "find optic mode: '$optic_mode'"
    [ -z "$optic_mode" ] && return

    # ensure that config includes the detected mode
    uci set "optic.common.mode=$optic_mode"
    if [ "$optic_mode" != "$pon_mode" ]; then
        log_console "[optic-db] pon-mode changed to $optic_mode"
        uci set "gpon.ponip.pon_mode=$optic_mode"
        uci commit gpon
    else
        log_console "[optic-db] pon-mode unchanged ($optic_mode)"
    fi
}

check_optic_change() {
    local optic_version optic_transceiver optic_change

    optic_version=$(uci -q get optic.common.version)
    optic_transceiver=$(uci -q get optic.common.transceiver_name)
    [ "$optic_version" != "$IMAGE_VERSION" ] && optic_change=1
    [ "$optic_transceiver" != "$TRANSCEIVER_NAME" ] && optic_change=1

    if [ "$optic_change" ]; then
        # Delete previous mode and transceiver configs.
        for opt in common.mode offsets gpon xgspon xgpon ngpon2_2G5 ngpon2_10G ; do
            uci -q delete optic.$opt;
        done
        config_apply optic "$OPTIC_DB_LOCATION/default"
        config_apply optic "$OPTIC_DB_LOCATION/default-$BOARD_NAME"
        config_apply optic $(optic_files_get "$BOARD_NAME")
        uci set optic.common.version="$IMAGE_VERSION"
        uci set optic.common.transceiver_name="$TRANSCEIVER_NAME"
        update_ponmode
        uci commit optic
    fi
}

check_serdes_change() {
    local serdes_version serdes_transceiver serdes_change

    serdes_version=$(uci -q get serdes.generic.version)
    serdes_transceiver=$(uci -q get serdes.generic.transceiver_name)
    [ "$serdes_version" != "$IMAGE_VERSION" ] && serdes_change=1
    [ "$serdes_transceiver" != "$TRANSCEIVER_NAME" ] && serdes_change=1

    if [ "$serdes_change" ]; then
        config_apply serdes $(serdes_files_get "$BOARD_NAME")
        uci set serdes.generic.version="$IMAGE_VERSION"
        uci set serdes.generic.transceiver_name="$TRANSCEIVER_NAME"
        uci commit serdes
    fi
}

EEPROM_PATH="$(uci -q get optic.sfp_eeprom.serial_id)"
if [ -z "$EEPROM_PATH" ]; then
    log_console "[pondb.sh] Failed to get EEPROM path from UCI"
    exit 1
fi

image_version_get

# check if dd supports needed flags for optimized read
if dd iflag=skip_bytes,count_bytes if=/dev/zero of=/dev/null count=1 2> /dev/null; then
    READ_EEPROM=read_eeprom_real_count
else
    READ_EEPROM=read_eeprom_bs1
fi

# get first transceiver name (most detailed) as reference
TRANSCEIVER_NAME=$(transceiver_names_get | head -n1)
BOARD_NAME="$(pon_board_base_name)"

# only execute when called directly
if [ "$(basename $0)" = "pondb.sh" ]; then
    check_optic_change
    check_serdes_change
fi
