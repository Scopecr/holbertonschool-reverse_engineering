#!/bin/bash

FILE="$1"

echo "ELF Header Information for '$FILE':"
echo "----------------------------------------"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File not found" >&2
    exit 1
fi

# Magic Number (first 16 bytes)
MAGIC=$(hexdump -n 16 -v -e '16/1 "%02x "' "$FILE" 2>/dev/null)
echo "Magic Number: $MAGIC"

# Initialize fields
CLASS=""
BYTE_ORDER=""
ENTRY_POINT=""

# Extract header
while IFS= read -r line; do
    case "$line" in
        *"Class:"*)
            CLASS=$(echo "$line" | cut -d':' -f2)
            ;;
        *"Data:"*)
            BYTE_ORDER=$(echo "$line" | cut -d':' -f2)
            # extract only "little endian" or "big endian"
            if [[ "$BYTE_ORDER" == *"little endian"* ]]; then
                BYTE_ORDER="little endian"
            elif [[ "$BYTE_ORDER" == *"big endian"* ]]; then
                BYTE_ORDER="big endian"
            fi
            ;;
        *"Entry point address:"*)
            ENTRY_POINT=$(echo "$line" | cut -d':' -f2 | tr -d ' ')
            ;;
    esac
done < <(readelf -h "$FILE" 2>/dev/null)

# Trim spaces
CLASS=$(echo "$CLASS" | tr -d '\n' | sed 's/^ *//;s/ *$//')

echo "Class: $CLASS"
echo "Byte Order: $BYTE_ORDER"
echo "Entry Point Address: $ENTRY_POINT"
