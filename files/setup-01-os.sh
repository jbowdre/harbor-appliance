#!/bin/bash

# OS Specific Settings where ordering does not matter

set -euo pipefail

# Enable & Start SSH
sed -i 's/.*PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
systemctl enable sshd
systemctl restart sshd

# Allow ICMP
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables-save > /etc/systemd/scripts/ip4save

# Ensure docker is stopped to allow config of network
systemctl stop docker

echo -e "\e[92mConfiguring OS admin account: ${ADMIN_USERNAME}..." > /dev/console
if ! id "$ADMIN_USERNAME" > /dev/null 2>&1; then
  useradd -m -s /bin/bash "${ADMIN_USERNAME}"
  usermod -aG sudo "${ADMIN_USERNAME}"
fi
sudo -u "${ADMIN_USERNAME}" mkdir -p "/home/${ADMIN_USERNAME}/.ssh"
echo "${ADMIN_USERNAME}:${ADMIN_PASSWORD}" | /usr/sbin/chpasswd
if [ -n "${ADMIN_PUBKEY}" ]; then
  echo "${ADMIN_PUBKEY}" | sudo -u "${ADMIN_USERNAME}" tee -a "/home/${ADMIN_USERNAME}/.ssh/authorized_keys"
fi

if [ "${DOCKER_NETWORK_CIDR}" != "172.17.0.1/16" ]; then
  echo -e "\e[92mConfiguring Docker Bridge Network ..." > /dev/console
  cat > /etc/docker/daemon.json << EOF
{
  "bip": "${DOCKER_NETWORK_CIDR}",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  }
}
EOF
fi

# Start Docker
systemctl start docker