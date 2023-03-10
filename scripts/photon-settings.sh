#!/bin/bash -eux

##
## Misc configuration
##

echo '> Applying latest Updates...'
sed -i 's/dl.bintray.com\/vmware/packages.vmware.com\/photon\/$releasever/g' /etc/yum.repos.d/*.repo
tdnf -y update photon-repos
tdnf clean all
tdnf makecache
tdnf -y update

echo '> Installing Additional Packages...'
tdnf install -y \
  wget \
  unzip \
  tar

echo '> Creating directory for setup scripts'
mkdir -p "/opt/harbor/setup"
chmod 755 /opt
chmod -R 755 /opt/harbor/

echo '> Downloading Harbor...'
curl -sL "https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-offline-installer-v${HARBOR_VERSION}.tgz" -o "/opt/harbor-offline-installer-v${HARBOR_VERSION}.tgz"
tar xvzf /opt/harbor-offline-installer*.tgz --directory=/opt/
rm -f "/opt/harbor-offline-installer-v${HARBOR_VERSION}.tgz"

echo '> Downloading docker-compose...'
curl -sL "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose