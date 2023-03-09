# Example environment-specific variables file.
# Copy this to 'env.auto.pkrvars.hcl' and update the values accordingly.

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