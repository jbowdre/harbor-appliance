# Example environment-specific variables file.
# Copy this to 'env.auto.pkrvars.hcl' and update the values accordingly.

# vSphere Environment
vsphere_cluster               = "Cluster-1"               # Cluster onto which the virtual machine template should be placed. If 'host' and 'cluster' are both specified, 'host' must be a member of 'cluster.'
vsphere_datacenter            = "Datacenter-1"            # Name of the vSphere Datacenter to deploy to.
vsphere_datastore             = "Datastore-1"             # Name of the vSphere datastore to deploy to.
vsphere_endpoint              = "vcenter.example.com"     # FQDN/IP of the vCenter to deploy to.
vsphere_folder                = "_Templates"              # Folder path (relative to vsphere_datacenter) where the template should be created.
vsphere_host                  = null                      # Host onto which the virtual machine template should be placed. If 'host' and 'cluster' are both specified, 'host' must be a member of 'cluster.'
vsphere_insecure_connection   = true                      # True to disable certificate verification.
vsphere_network               = "Network-1"               # Name of the virtual portgroup to deploy to.
vsphere_password              = "hunter2"                 # Password to authenticate with the vSphere endpoint.
vsphere_username              = "packer"                  # Username to authenticate with the vSphere endpoint.
