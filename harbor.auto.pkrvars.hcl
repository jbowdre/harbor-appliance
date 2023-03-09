# Harbor
harbor_compose_version    = "2.16.0"
harbor_ovf_template       = "photon.xml.template"
harbor_version            = "2.7.1"

# Appliance Config
appliance_def_admin_user  = "admin"
appliance_def_dns         = "192.168.1.5"
appliance_def_domain      = "example.com"
appliance_def_gateway     = "192.168.1.1"
appliance_def_hostname    = "harbor.example.com"
appliance_def_ip          = "192.168.1.10"
appliance_def_ntp         = "pool.ntp.org"
appliance_product         = "Harbor Appliance"
appliance_product_url     = "https://github.com/jbowdre/harbor-appliance"
appliance_vendor          = "VirtuallyPotato"
appliance_vendor_url      = "https://virtuallypotato.com"

# Guest Partitioning (in MB)
guest_part_boot           = 128
guest_part_docker         = 81920
guest_part_log            = 512
guest_part_root           = 0
guest_part_swap           = 512
guest_part_tmp            = 512
guest_part_var            = 512

# VM Config
vm_cpu_count              = 2
vm_disk_size              = 102400
vm_mem_size               = 4096
vm_version                = 14
vm_name                   = "HarborAppliance"

# Other Settings
boot_command = [
  "<esc><wait>c",
  "linux /isolinux/vmlinuz root=/dev/ram0 loglevel=3 insecure_installation=1 ks=/dev/sr1:/ks.json photon.media=cdrom",
  "<enter>",
  "initrd /isolinux/initrd.img",
  "<enter>",
  "boot",
  "<enter>"
]
boot_order                = "disk,cdrom"
boot_wait                 = "2s"
cd_label                  = "cidata"
iso_checksum              = "5af288017d0d1198dd6bd02ad40120eb"
iso_file                  = null
iso_url                   = "https://packages.vmware.com/photon/4.0/Rev2/iso/photon-4.0-c001795b8.iso"
ovf_export_enabled        = true
ovf_export_overwrite      = true
ovf_export_path           = "./output-vsphere-iso/"
package_list              = [
  "cloud-utils",
  "initramfs",
  "linux",
  "logrotate",
  "openssl-c_rehash",
  "parted",
  "sudo",
  "vim"
                          ]
remove_cdrom              = true
remove_keys               = true
shutdown_command          = "/sbin/shutdown -h now"
shutdown_timeout          = "5m"
vm_cdrom_type             = "sata"
vm_cpu_hotplug            = true
vm_disk_controller_type   = ["pvscsi"]
vm_disk_thin_provisioned  = true
vm_firmware               = "efi-secure"
vm_guest_os_type          = "vmwarePhoton64Guest"
vm_mem_hotplug            = true
vm_network_card           = "vmxnet3"
vm_tools_upgrade_policy   = true

