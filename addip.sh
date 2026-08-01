#!/bin/bash

# ==========================================
# Script: Check and Update /etc/hosts
# Description: This script checks if a specific 
# IP and domain mapping already exists in /etc/hosts.
# If it doesn't exist, it safely appends it.
# ==========================================

# Define the target IP address, domain name, and hosts file path
IP="127.0.0.1"
DOMAIN="app.test"
HOSTS_FILE="/etc/hosts"

# Print a message indicating the start of the check
echo "Checking if '${IP} ${DOMAIN}' exists in ${HOSTS_FILE}..."

# Check if the entry already exists in the hosts file
# -q: Quiet mode (suppresses normal output)
# -E: Use extended regular expressions
# The regex checks for lines starting with optional spaces, followed by the IP, one or more spaces, and the domain.
if grep -q -E "^[[:space:]]*${IP}[[:space:]]+${DOMAIN}" "$HOSTS_FILE"; then
    echo "-> Entry already exists. No changes needed."
else
    echo "-> Entry not found. Adding it to ${HOSTS_FILE}..."
    
    # Append the IP and domain to the hosts file using 'sudo' and 'tee'
    # 'tee -a' allows us to write to a protected system file with elevated privileges via sudo
    # '> /dev/null' hides the standard output of the tee command to keep the terminal clean
    echo "${IP} ${DOMAIN}" | sudo tee -a "$HOSTS_FILE" > /dev/null
    
    # Check if the previous command executed successfully ($? equals 0)
    if [ $? -eq 0 ]; then
        echo "-> Success! The entry has been added."
    else
        echo "-> Error: Failed to add the entry (insufficient sudo privileges or read-only file)."
        exit 1
    fi
fi
