#!/bin/bash

# Generate a CA certificate private key
mkdir -p /opt/harbor/certs/
openssl genrsa -out /opt/harbor/certs/ca.key 4096

# Generate the CA certificate
openssl req -x509 -new -nodes -sha512 -days 3650 \
  -subj "/C=US/ST=California/L=Palo Alto/CN=${HOSTNAME}" \
  -key /opt/harbor/certs/ca.key \
  -out /opt/harbor/certs/ca.crt

# Generate a private key
openssl genrsa -out "/opt/harbor/certs/${HOSTNAME}.key" 4096

# Generate a certificate signing request (CSR)
openssl req -sha512 -new \
  -subj "/C=US/ST=California/L=Palo Alto/CN=${HOSTNAME}" \
  -key "/opt/harbor/certs/${HOSTNAME}.key" \
  -out "/opt/harbor/certs/${HOSTNAME}.csr"

# Generate an x509 v3 extension file
cat > /opt/harbor/certs/v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=${HOSTNAME}
DNS.2=${DNS_DOMAIN}
EOF

# Generate a certificate for your Harbor host using v3.ext
openssl x509 -req -sha512 -days 3650 \
  -extfile /opt/harbor/certs/v3.ext \
  -CA /opt/harbor/certs/ca.crt -CAkey /opt/harbor/certs/ca.key -CAcreateserial \
  -in "/opt/harbor/certs/${HOSTNAME}.csr" \
  -out "/opt/harbor/certs/${HOSTNAME}.crt"

# Configure certificate for Docker
mkdir -p /data/cert/
cp "/opt/harbor/certs/${HOSTNAME}.crt" /data/cert/
cp "/opt/harbor/certs/${HOSTNAME}.key" /data/cert/

openssl x509 -inform PEM -in "/opt/harbor/certs/${HOSTNAME}.crt" -out "/opt/harbor/certs/${HOSTNAME}.cert"

mkdir -p "/etc/docker/certs.d/${HOSTNAME}/"
cp "/opt/harbor/certs/${HOSTNAME}.cert" "/etc/docker/certs.d/${HOSTNAME}/"
cp "/opt/harbor/certs/${HOSTNAME}.key" "/etc/docker/certs.d/${HOSTNAME}/"
cp /opt/harbor/certs/ca.crt "/etc/docker/certs.d/${HOSTNAME}/"

# Creating Harbor configuration
HARBOR_CONFIG=harbor.yml
cd /opt/harbor || exit 1
mv /opt/harbor/harbor.yml.tmpl "/opt/harbor/${HARBOR_CONFIG}"
sed -i "s/hostname:.*/hostname: ${HOSTNAME}/g" "${HARBOR_CONFIG}"
sed -i "s/certificate:.*/certificate: \/etc\/docker\/certs.d\/${HOSTNAME}\/${HOSTNAME}.cert/g" "${HARBOR_CONFIG}"
sed -i "s/private_key:.*/private_key: \/etc\/docker\/certs.d\/${HOSTNAME}\/${HOSTNAME}.key/g" "${HARBOR_CONFIG}"
sed -i "s/harbor_admin_password:.*/harbor_admin_password: ${HARBOR_PASSWORD}/g" "${HARBOR_CONFIG}"
sed -i "s/password:.*/password: ${HARBOR_PASSWORD}/g" "${HARBOR_CONFIG}"

# Installing Harbor with Trivy scanner
./install.sh --with-trivy
rm -f harbor.*.gz

# Waiting for Harbor to be ready, sleeping for 90 seconds
sleep 90

#Enable Harbor as a Systemd Service
cat > /etc/systemd/system/harbor.service << __HARBOR_SYSTEMD__
[Unit]
Description=Harbor Service
After=network.target docker.service
[Service]
Type=simple
WorkingDirectory=/harbor/harbor
ExecStart=/usr/local/bin/docker-compose -f /opt/harbor/docker-compose.yml start
ExecStop=/usr/local/bin/docker-compose -f /opt/harbor/docker-compose.yml stop
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
__HARBOR_SYSTEMD__

systemctl enable harbor
