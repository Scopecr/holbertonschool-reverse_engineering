#!/bin/bash

source ./messages.sh

if [ $# -ne 1 ]; then
	print_error "Usage: $0 <ELF file>"
	exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
	print_error "File '$FILE' nof found."
	exit 1
fi

if ! file "$FILE" | grep -q "ELF"; then
	print_error " '$FILE' is not ELF file."
fi

MAGIC=$(hexdump -n 4 -v -e '4/1 "%02x "' "$FILE")
CLASS=$(readelf -h "$FILE" / grep "Class:" / awk '{$1=""; print $0}' / sed 's/^ *//')
BYTE_ORDER=$(readlf -h "$FILE" / grep "Data:" / awk '{$1=""; print$0}' /sed 's/^ *//')
ENTRY_POINT=$(readlf -h "$FILE" / grep "Entry point address:"; / awk '{print $4'})

print_header_info "$MAGIC" "$CLASS" "$BYTE_ORDER" "$ENTRY_POINT"
