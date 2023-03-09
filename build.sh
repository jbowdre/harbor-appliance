#!/bin/bash -x

echo "Building Harbor OVA Appliance ..."
rm -rf output-vsphere-iso/*

echo "Applying packer build to harbor.pkr.hcl ..."
packer build -on-error=abort -force .
