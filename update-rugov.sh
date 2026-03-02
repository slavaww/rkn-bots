#!/bin/bash

set -euo pipefail

# Configuration
URL="https://github.com/C24Be/AS_Network_List/raw/main/blacklists/blacklist.txt"
LOG_FILE="/var/log/rugov_blacklist/blacklist_updater.log"
TMP_RAW=$(mktemp)

# Create a folder for logs if there is none
mkdir -p "$(dirname "$LOG_FILE")"

# We create a table structure if it has been erased or not created
nft -f /etc/nftables.rugov.conf || true

echo "$(date +"%Y-%m-%d %H:%M:%S") Starting update..." >> "$LOG_FILE"

# Download the list
wget -qO "$TMP_RAW" "$URL"
sed -i 's/\r//g' "$TMP_RAW"

# Clearing old entries
nft flush set inet rugov_block blacklist_v4
nft flush set inet rugov_block blacklist_v6

echo "$(date +"%Y-%m-%d %H:%M:%S") Uploading addresses to nftables..." >> "$LOG_FILE"

# Filling IPv4
grep -v ":" "$TMP_RAW" | grep "/" | xargs -I {} nft add element inet rugov_block blacklist_v4 { {} } 2>/dev/null || true

# Filling IPv6
grep ":" "$TMP_RAW" | grep "/" | xargs -I {} nft add element inet rugov_block blacklist_v6 { {} } 2>/dev/null || true

# Checking the result
count_v4=$(nft list set inet rugov_block blacklist_v4 | grep -c '/')
count_v6=$(nft list set inet rugov_block blacklist_v6 | grep -c '/')

echo "$(date +"%Y-%m-%d %H:%M:%S") Done! Blacklist updated. Nftables sets updated. IPv4 entries: $count_v4, IPv6 entries: $count_v6" >> "$LOG_FILE"
rm -f "$TMP_RAW"