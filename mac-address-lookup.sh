#!/usr/bin/env bash

# Author: Erwin Pacua <erwin.pacua@gmail.com
# Date:   Mon Nov 09 21:43:16 2020 +1300

#                    GNU AFFERO GENERAL PUBLIC LICENSE
#                       Version 3, 19 November 2007
#
# Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.

OUI_SRC="https://www.wireshark.org/download/automated/data/manuf"
FILE="oui-db.txt"

if [[ ! -f "${FILE}" ]]; then
	echo "MAC address database not found. Downloading it from ${OUI_SRC}"
	wget -qO "$FILE" $OUI_SRC
else
	echo -e "Using the MAC address database '$FILE' retrieved from wireshark.org.\n"
fi

# Assign a hash for each pair of interface:mac_address
declare -A INTF_HASH=()

# Retrieve all interfaces except the loopback
OUI=$(ip -o link | sed -n 's/^[0-9][0-9]\?: \([[:alnum:]]\+\).\+\([[:xdigit:]:]\{17\}\) brd.\+$/\1 \2/1p' | grep -v '^\<lo\>')

# Populate `INTF_HASH` by splitting $REPLY - the default iterator in bash.
while read; do
	INTF_HASH[${REPLY% *}]=${REPLY#* }
done <<<$OUI

# Match the interfaces against the OUI database grabbed from wireshark.org
for intf in "${!INTF_HASH[@]}"; do
	MAC=$(echo ${INTF_HASH[$intf]} | tr 'a-f' 'A-F')
	MANUFACTURER=$(grep "${MAC:0:8}" $FILE | cut -d'	' -f3)
	echo "--------------------------------------------"
	echo "  INTERFACE:    $intf"
	echo "  MAC ADDRESS:  ${INTF_HASH[$intf]}"
	echo "  MANUFACTURER: $MANUFACTURER"
	echo "============================================"
	echo
done

echo "Thank you for using this program!"
