variable "appliance_def_admin_user" {
  type          = string
  description   = "Default admin username for the appliance."
}

variable "appliance_def_hostname" {
  type          = string
  description   = "Default hostname for the appliance."
}

variable "appliance_def_ip" {
  type          = string
  description   = "Default IP address for the appliance."
}

variable "appliance_def_gateway" {
  type          = string
  description   = "Default gateway address for the appliance."
}

variable "appliance_def_ntp" {
  type          = string
  description   = "Default NTP server for the appliance."
}

variable "appliance_def_dns" {
  type          = string
  description   = "Default DNS server for the appliance."
}

variable "appliance_def_domain" {
  type          = string
  description   = "Default domain for the appliance."
}

variable "appliance_product" {
  type          = string
  description   = "Product name for the appliance."
}

variable "appliance_product_url" {
  type          = string
  description   = "Product URL for the appliance."
}

variable "appliance_vendor" {
  type          = string
  description   = "Vendor name for the appliance."
}

variable "appliance_vendor_url" {
  type          = string
  description   = "URL for the appliance vendor."
}

variable "boot_command" {
  type          = list(string)
  description   = "The virtual machine boot command."
  default       = []
}

variable "boot_order" {
  type          = string
  description   = "The boot order for virtual machines devices. (e.g. 'disk,cdrom')"
  default       = "disk,cdrom"
}

variable "boot_wait" {
  type          = string
  description   = "The time to wait before boot."
}

variable "cd_label" {
  type          = string
  description   = "Media label for the optical drive."
}

variable "guest_part_boot" {
  type          = number
  description   = "Size of the /boot partition in MB."
}

variable "guest_part_docker" {
  type          = number
  description   = "Size of the /var/lib/docker partition in MB."
}

variable "guest_part_log" {
  type          = number
  description   = "Size of the /var/log partition in MB."
}

variable "guest_part_root" {
  type          = number
  description   = "Size of the / partition in MB. Set to 0 to consume all remaining free space."
  default       = 0
}

variable "guest_part_swap" {
  type          = number
  description   = "Size of the swap partition in MB."
}

variable "guest_part_tmp" {
  type          = number
  description   = "Size of the /tmp partition in MB."
}

variable "guest_part_var" {
  type          = number
  description   = "Size of the /var partition in MB."
}

variable "harbor_compose_version" {
  type          = string
  description   = "Version number for docker-compose (from https://github.com/docker/compose/releases)"
}

variable "harbor_ovf_template" {
  type          = string
  description   = "Path to the XML template used for setting OVF properties."
}

variable "harbor_version" {
  type          = string
  description   = "Version number for the Harbor release (from https://github.com/goharbor/harbor/releases/)"
}

variable "iso_checksum" {
  type          = string
  description   = "The checksum value provided by the vendor."
}

variable "iso_file" {
  type          = string
  description   = "The file name of the ISO image used by the vendor. (e.g. 'ubuntu-<version>-live-server-amd64.iso')"
}

variable "iso_url" {
  type          = string
  description   = "The URL source of the ISO image. (e.g. 'https://artifactory.rainpole.io/.../os.iso')"
}

variable "ovf_export_enabled" {
  type          = bool
  description   = "Enable OVF artifact export."
  default       = false
}

variable "ovf_export_overwrite" {
  type          = bool
  description   = "Overwrite existing OVF artifiact."
  default       = true
}

variable "ovf_export_path" {
  type          = string
  description   = "Folder path for the OVF export."
}

variable "package_list" {
  type          = list(string)
  description   = "List of packages to be installed during initial boot."
  default       = []
}

variable "remove_cdrom" {
  type          = bool
  description   = "Remove the virtual CD-ROM(s)."
  default       = true
}

variable "remove_keys" {
  type          = bool
  description   = "Remove the temporary SSH key(s) used by Packer during the build."
}

variable "shutdown_command" {
  type          = string
  description   = "Command(s) for guest operating system shutdown."
  default       = null
}

variable "shutdown_timeout" {
  type          = string
  description   = "How long to wait for shutdown to execute."
}

variable "vm_cdrom_type" {
  type          = string
  description   = "Which controller to use. Example: 'sata'. Defaults to 'ide'"
}

variable "vm_cpu_count" {
  type          = number
  description   = "The number of virtual CPUs. (e.g. '2')"
}

variable "vm_cpu_hotplug" {
  type          = bool
  description   = "Enable hot add CPU."
  default       = true
}

variable "vm_disk_controller_type" {
  type          = list(string)
  description   = "The virtual disk controller types in sequence. (e.g. 'pvscsi')"
  default       = ["pvscsi"]
}

variable "vm_disk_size" {
  type          = number
  description   = "The size for the virtual disk in MB. (e.g. '61440' = 60GB)"
}

variable "vm_disk_thin_provisioned" {
  type          = bool
  description   = "Thin provision the virtual disk."
}

variable "vm_firmware" {
  type          = string
  description   = "The virtual machine firmware type ('efi-secure', 'efi', or 'bios')."
}

variable "vm_guest_os_type" {
  type          = string
  description   = "The guest operating system type, also know as guestid. (e.g. 'ubuntu64Guest')"
}

variable "vm_mem_hotplug" {
  type          = bool
  description   = "Enable hot add memory."
  default       = true
}

variable "vm_mem_size" {
  type          = number
  description   = "The size for the virtual memory in MB. (e.g. '2048')"
}

variable "vm_name" {
  type          = string
  description   = "Name of the new VM to create."
}

variable "vm_network_card" {
  type          = string
  description   = "Set VM network card type."
}

variable "vm_tools_upgrade_policy" {
  type          = bool
  description   = "Upgrade VMware Tools on reboot."
  default       = true
}

variable "vm_version" {
  type          = number
  description   = "The vSphere virtual hardware version. (e.g. '19')"
}

variable "vsphere_cluster" {
  type          = string
  description   = "Cluster onto which the virtual machine template should be placed. If 'host' and 'cluster' are both specified, 'host' must be a member of 'cluster.'"
  default       = null
}

variable "vsphere_datacenter" {
  type          = string
  description   = "Name of the vSphere Datacenter to deploy to."
}

variable "vsphere_datastore" {
  type          = string
  description   = "Name of the vSphere datastore to deploy to."
}

variable "vsphere_endpoint" {
  type          = string
  description   = "FQDN/IP of the vCenter to deploy to."
}

variable "vsphere_folder" {
  type          = string
  description   = "Folder path (relative to vsphere_datacenter) where the template should be created."
}

variable "vsphere_host" {
  type          = string
  description   = "Host onto which the virtual machine template should be placed. If 'host' and 'cluster' are both specified, 'host' must be a member of 'cluster.'"
  default       = null
}

variable "vsphere_insecure_connection" {
  type          = bool
  description   = "True to disable certificate verification."
  default       = false
}

variable "vsphere_network" {
  type          = string
  description   = "Name of the virtual portgroup to deploy to."
}

variable "vsphere_password" {
  type          = string
  description   = "Password to authenticate with the vSphere endpoint."
  sensitive     = true
}

variable "vsphere_username" {
  type          = string
  description   = "Username to authenticate with the vSphere endpoint."
}
