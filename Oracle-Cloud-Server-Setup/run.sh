#!/bin/bash

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Remove existing Docker installations
echo "🗑️ Removing existing Docker installations..."
sudo apt remove --purge docker.io docker-compose containerd containerd.io -y

# Install Docker
echo "🐳 Installing Docker..."
sudo apt install docker.io docker-compose -y

# Install CasaOS
echo "🏠 Installing CasaOS..."
curl -fsSL https://get.casaos.io | sudo bash

# Create a temporary file
temp_file=$(mktemp)

# Process the rules file line by line
while IFS= read -r line; do
    echo "$line" >> "$temp_file"
    if [[ "$line" == *"--dport 22 -j ACCEPT"* ]]; then
        # Add our new rules after the SSH rule
        echo "# Allow HTTP and HTTPS" >> "$temp_file"
        echo "-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT" >> "$temp_file"
        echo "-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT" >> "$temp_file"
        echo "" >> "$temp_file"
    fi
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
