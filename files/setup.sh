#!/bin/bash
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

set -euo pipefail

# Extract all OVF Properties
ADMIN_PASSWORD=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.admin_password")
ADMIN_PUBKEY=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.admin_pubkey")
ADMIN_USERNAME=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.admin_username")
DEBUG=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.debug")
DNS_DOMAIN=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.domain")
DNS_SERVER=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.dns")
DOCKER_NETWORK_CIDR=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.docker_network_cidr")
GATEWAY=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.gateway")
HARBOR_PASSWORD=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.harbor_password")
HOSTNAME=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.hostname")
IP_ADDRESS=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.ipaddress")
NETMASK=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.netmask" | awk -F ' ' '{print $1}')
NTP_SERVER=$(/opt/harbor/setup/getOvfProperty.py "guestinfo.ntp")

if [ -e /harbor/setup/.ran_customization ]; then
    exit
else
	HARBOR_LOG_FILE=/var/log/bootstrap.log
	if [ "${DEBUG}" == "True" ]; then
		HARBOR_LOG_FILE=/var/log/bootstrap-debug.log
    touch ${HARBOR_LOG_FILE}
    chmod 600 ${HARBOR_LOG_FILE}
		set -x
		exec 2>> ${HARBOR_LOG_FILE}
		echo
        echo "### WARNING -- DEBUG LOG CONTAINS ALL EXECUTED COMMANDS WHICH INCLUDES CREDENTIALS -- WARNING ###"
        echo "### WARNING --             PLEASE REMOVE CREDENTIALS BEFORE SHARING LOG            -- WARNING ###"
        echo
	fi

	echo -e "\e[92mStarting Customization ..." > /dev/console

	echo -e "\e[92mStarting OS Configuration ..." > /dev/console
	. /opt/harbor/setup/setup-01-os.sh

	echo -e "\e[92mStarting Network Configuration ..." > /dev/console
	. /opt/harbor/setup/setup-02-network.sh

	echo -e "\e[92mStarting Harbor Configuration ..." > /dev/console
	. /opt/harbor/setup/setup-03-harbor.sh

	echo -e "\e[92mCustomization Completed ..." > /dev/console

	# Clear guestinfo.ovfEnv
	vmtoolsd --cmd "info-set guestinfo.ovfEnv NULL"

	# Ensure we don't run customization again
	touch /opt/harbor/setup/.ran_customization
fi