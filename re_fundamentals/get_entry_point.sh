#!/bin/bash

FILE="$1"

echo "ELF Header Information for '$FILE':"
echo "----------------------------------------"

if [ ! -f "$FILE" ]; then
    echo "Error: File not found" >&2
    exit 1
fi

MAGIC=$(hexdump -n 16 -v -e '16/1 "%02x "' "$FILE" 2>/dev/null)
MAGIC_UPPER=$(echo "$MAGIC" | tr 'a-f' 'A-F')
MAGIC_SPACED=$(echo "$MAGIC_UPPER" | sed 's/../& /g' | tr -s ' ')

HEADER=$(readelf -h "$FILE" 2>/dev/null)

CLASS=""
BYTE_ORDER=""
ENTRY_POINT=""

while IFS= read -r line; do
    case "$line" in
        *Class:*)
            CLASS=${line##*:}
            CLASS=$(echo "$CLASS" | xargs)
            ;;
        *Data:*)
            BYTE_ORDER=${line##*:}
            BYTE_ORDER=$(echo "$BYTE_ORDER" | xargs | cut -d',' -f2)
            ;;
        *"Entry point address:"*)
            ENTRY_POINT=$(echo "$line" | awk '{print $4}')
            ;;
    esac
done <<< "$HEADER"

echo "Magic Number: $MAGIC_SPACED"
echo "Class: $CLASS"
echo "Byte Order: $BYTE_ORDER"
echo "Entry Point Address: $ENTRY_POINT"
