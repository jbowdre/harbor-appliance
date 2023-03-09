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

## Procedure
Step 1 - Clone the git repository
```
git clone https://github.com/jbowdre/harbor-appliance.git
```

Step 2 - Copy `env-example.pkrvars.hcl` to `env.auto.pkrvars.hcl` and update accordingly:
```
# vSphere Environment
vsphere_cluster               = "Cluster-1"
vsphere_datacenter            = "Datacenter-1"
vsphere_datastore             = "Datastore-1"
vsphere_endpoint              = "vcenter.example.com"
vsphere_folder                = "_Templates"
vsphere_host                  = null
vsphere_insecure_connection   = true
vsphere_network               = "Network-1"
vsphere_password              = "hunter2"
vsphere_username              = "packer"

# Guest Credentials
guest_root_password           = "hunter2"
```

Step 3 - Review `harbor.auto.pkrvars.hcl` and change any other options you think might be fun.

Step 4 - Start the build by running the build script which simply calls Packer and the respective build files
```
./build.sh
````

If the build was successful, you will find the Harbor OVA located in `output-vsphere-iso/HarborAppliance.ova`

You can then [deploy the OVA to vSphere](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-17BEDA21-43F6-41F4-8FB2-E01D275FE9B4.html) like usual. You'll be prompted to set up the initial settings during the template deployment. Once the VM boots up, follow the [What to Do Next](https://goharbor.io/docs/2.7.0/install-config/run-installer-script/#what-to-do-next) instructions to get up and running.

Harbor will be installed in `/opt/harbor/` on the appliance in case you need to [reconfigure anything there](https://goharbor.io/docs/2.7.0/install-config/reconfigure-manage-lifecycle/).
