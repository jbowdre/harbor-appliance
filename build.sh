#!/bin/bash -x

echo "Building Harbor OVA Appliance ..."
rm -f output-vsphere-iso/*.ova

echo "Applying packer build to photon.pkr.hcl ..."
packer build photon.pkr.hcl