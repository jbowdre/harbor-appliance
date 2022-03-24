# Reference for building VMware Harbor Virtual Appliance (OVA) using Packer
Adapted from [William Lam's work](https://github.com/lamw/harbor-appliance) to:
- Translate from JSON to HCL format
- Migrate from the [`vmware-iso` builder](https://www.packer.io/plugins/builders/vmware/iso) to the[`vsphere-iso` one](https://www.packer.io/plugins/builders/vsphere/vsphere-iso) which
  - Leverages an API connection to vCenter instead of SSH connection to the host
  - Eliminates the need for the `/Net/GuestIPHack` advanced configuration for ESXi
  - Supports connecting the template VM to a dvPortGroup 

## Requirements

* MacOS or Linux Desktop
* vCenter Server
* vSphere Cluster running ESXi 6.5+ (DRS not required, single host will do)
* [VMware OVFTool](https://developer.vmware.com/web/tool/4.4.0/ovf)
* [Packer](https://www.packer.io/intro/getting-started/install.html)
* [PowerCLI](https://developer.vmware.com/powercli/installation-guide) (for removing source VM after OVA export)
* Packer account in vCenter with [appropriate permissions](https://www.packer.io/plugins/builders/vsphere/vsphere-iso#required-vsphere-privileges)


> `packer` builds the OVA on a remote ESXi host via the [`vsphere-iso`](https://www.packer.io/plugins/builders/vsphere/vsphere-iso) builder. 

Step 1 - Clone the git repository

```
git clone https://github.com/jbowdre/harbor-appliance.git
```

Step 2 - Edit the `photon.pkrvars.hcl` file to configure the local vSphere endpoint for building the Harbor appliance

```
builder_cluster             = "physical-cluster"
builder_host                = "nuchost.lab.bowdre.net"
builder_datastore           = "nuchost-local"
builder_portgroup           = "MGT-Home 192.168.1.0"
builder_vcenter             = "vcsa.lab.bowdre.net"
builder_vcenter_username    = "packer@lab.bowdre.net"
builder_vcenter_password    = "VMware1!"
builder_datacenter          = "Lab"
```

**Note:** If you need to change the initial root password on the Harbor appliance, take a look at `photon.pkr.hcl` and `http/photon-kickstart.json`. When the OVA is produced, there is no default password, so this does not really matter other than for debugging purposes.

Step 3 - Start the build by running the build script which simply calls Packer and the respective build files

```
./build.sh
````

If the build was successful, you will find the Harbor OVA located in `output-vsphere-iso/VMware_Harbor_Appliance.ova`
