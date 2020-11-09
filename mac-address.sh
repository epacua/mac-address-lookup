#!/usr/bin/env bash

# Author: Erwin Pacua <erwin.pacua@gmail.com
# Date:   Mon Nov 09 21:43:16 2020 +1300

#                    GNU AFFERO GENERAL PUBLIC LICENSE
#                       Version 3, 19 November 2007
#
# Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.

OLDIFS="$IFS"
IFS=' '
FILE="/tmp/oui.txt"
SOURCE="https://gitlab.com/wireshark/wireshark/-/raw/master/manuf"

if [[ ! -f "${FILE}" ]]; then
  echo "$FILE not found. Downloading it from ${SOURCE}"
  wget -qO "$FILE" https://gitlab.com/wireshark/wireshark/-/raw/master/manuf
else
  echo -e "\nFile $FILE found\n"
fi

declare -A INTF_HASH
OUI=$(ip link | sed -n '1,2d;N;s/\n//;s/^[2-9]: \(\w\+\):.\+\([[:xdigit:]:]\{17\}\).\+/\1 \2/p')

while read; do
	INTERFACE=$(cut -d' ' -f1 <(echo $REPLY)) && MAC=$(cut -d' ' -f2 <(echo $REPLY) | tr 'a-f' 'A-F')
	MANUFACTURER=$(grep "${MAC:0:8}" $FILE | cut -d'	' -f3)
	echo "INTERFACE: ${INTERFACE} -- ${MAC} -- $MANUFACTURER"
	INTF_HASH+=( [$(echo "$INTERFACE")]=$(echo "$MAC") )
done < <(echo $OUI)

IFS="$OLDIFS"
