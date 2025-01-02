#!/bin/bash

# Create a temporary file
temp_file=$(mktemp)

# Process the rules file line by line
while IFS= read -r line; do
    if [[ "$line" == "COMMIT" ]]; then
        # Add our new rules just before COMMIT
        echo "# Allow HTTP and HTTPS" >> "$temp_file"
        echo "-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT" >> "$temp_file"
        echo "-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT" >> "$temp_file"
        echo "" >> "$temp_file"
    fi
    echo "$line" >> "$temp_file"
done < /etc/iptables/rules.v4

# Replace the original file with our modified version
cat "$temp_file" > /etc/iptables/rules.v4
rm "$temp_file"

echo "✅ Successfully added iptables rules"

# Apply the rules
if iptables-restore < /etc/iptables/rules.v4; then
    echo "✅ Successfully applied iptables rules"
else
    echo "❌ Failed to apply iptables rules"
    exit 1
fi
