#!/bin/bash -x

echo "Building Harbor OVA Appliance ..."
rm -f output-vsphere-iso/*.ova

echo "Applying packer build to photon.pkr.hcl ..."
packer build -var-file="photon.pkrvars.hcl" photon.pkr.hcl