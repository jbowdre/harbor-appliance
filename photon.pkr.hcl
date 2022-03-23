packer {
  required_version = ">= 1.6.3"
}

# vm vars
variable "version" {
  type      = string
  default   = "2.4.1"
}

variable "description" {
  type      = string
  default   = "VMware Harbor Appliance"
}

variable "vm_name" {
  type      = string
  default   = "VMware_Harbor_Appliance"
}

variable "iso_checksum" {
  type      = string
  default   = "5af288017d0d1198dd6bd02ad40120eb"
}

variable "iso_url" {
  type      = string
  default   = "https://packages.vmware.com/photon/4.0/Rev2/iso/photon-4.0-c001795b8.iso"
}

variable "numvcpus" {
  type      = string
  default   = "2"
}

variable "ramsize" {
  type      = string
  default   = "4096"
}

variable "guest_username" {
  type      = string
  default   = "root"
}

variable "guest_password" {
  sensitive = true
  type      = string
  default   = "VMware1!"
}

# builder vars
variable "builder_cluster" {
  type      = string
  default   = "physical-cluster"
}

variable "builder_host" {
  type      = string
  default   = "nuchost.lab.bowdre.net"
}

variable "builder_datastore" {
  type      = string
  default   = "nuchost-local"
}

variable "builder_portgroup" {
  type      = string
  default   = "MGT-Home 192.168.1.0"
}

variable "builder_vcenter" {
  type      = string
  default   = "vcsa.lab.bowdre.net"
}

variable "builder_vcenter_username" {
  type      = string
  default   = "packer@lab.bowdre.net"
}

variable "builder_vcenter_password" {
  sensitive = true
  type      = string
  default   = "VMware1!"
}

variable "builder_datacenter" {
  type      = string
  default   = "Lab"
}

variable "photon_ovf_template" {
  type    = string
  default = "photon.xml.template"
}

source "vsphere-iso" "harbor" {

  # build source
  iso_checksum              = "${var.iso_checksum}"
  iso_url                   = "${var.iso_url}"

  # vsphere connection      
  vcenter_server            = "${var.builder_vcenter}"
  username                  = "${var.builder_vcenter_username}"
  password                  = "${var.builder_vcenter_password}"
  insecure_connection       = true

  # placement
  cluster                   = "${var.builder_cluster}"
  host                      = "${var.builder_host}"
  datastore                 = "${var.builder_datastore}"
  datacenter                = "${var.builder_datacenter}"

  # vm properties     
  vm_name                   = "${var.vm_name}"
  notes                     = "Version: ${var.version}"
  vm_version                = "13"
  guest_os_type             = "vmwarePhoton64Guest"
  CPUs                      = "${var.numvcpus}"
  CPU_hot_plug              = true
  RAM                       = "${var.ramsize}"
  RAM_hot_plug              = true
  disk_controller_type      = ["pvscsi"]
  storage {   
    disk_size               = "102400"
    disk_thin_provisioned   = true
  }
  network_adapters {    
    network                 = "${var.builder_portgroup}"
    network_card            = "vmxnet3"
  }   

  # boot properties   
  http_directory            = "http"
  boot_command              = [
    "<esc><wait>",    
    "vmlinuz initrd=initrd.img root=/dev/ram0 loglevel=3 ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/photon-kickstart.json photon.media=cdrom insecure_installation=1",
     "<enter>"]
  boot_wait                 = "10s"

  # guest connection    
  shutdown_command          = "/sbin/shutdown -h now"
  shutdown_timeout          = "1000s"
  ssh_password              = "${var.guest_password}"
  ssh_username              = "${var.guest_username}"
  ssh_port                  = 22
  
  # export
  export {
    force                   = true
    output_directory        = "./output-vsphere-iso/"
  }
}

build {
  sources                   = ["source.vsphere-iso.harbor"]

  provisioner "shell" {
    scripts                 = ["scripts/photon-settings.sh"]
  }

  provisioner "shell" {
    expect_disconnect       = true
    scripts                 = ["scripts/photon-docker.sh"]
  }

  provisioner "shell" {
    pause_before            = "20s"
    scripts                 = ["scripts/photon-cleanup.sh"]
  }

  provisioner "file" {
    destination             = "/etc/rc.d/rc.local"
    source                  = "files/rc.local"
  }

  provisioner "file" {
    destination             = "/root/setup/getOvfProperty.py"
    source                  = "files/getOvfProperty.py"
  }

  provisioner "file" {
    destination             = "/root/setup/setup.sh"
    source                  = "files/setup.sh"
  }

  provisioner "file" {
    destination             = "/root/setup/setup-01-os.sh"
    source                  = "files/setup-01-os.sh"
  }

  provisioner "file" {
    destination             = "/root/setup/setup-02-network.sh"
    source                  = "files/setup-02-network.sh"
  }

  provisioner "file" {
    destination             = "/root/setup/setup-03-harbor.sh"
    source                  = "files/setup-03-harbor.sh"
  }

  post-processor "shell-local" {
    environment_vars        = ["PHOTON_VERSION=${var.version}", "PHOTON_APPLIANCE_NAME=${var.vm_name}", "FINAL_PHOTON_APPLIANCE_NAME=${var.vm_name}", "PHOTON_OVF_TEMPLATE=${var.photon_ovf_template}"]
    inline                  = ["cd manual", "./add_ovf_properties.sh"]
  }

  post-processor "shell-local" {
    inline                  = ["pwsh -F unregister_vm.ps1 ${var.builder_vcenter} ${var.builder_vcenter_username} ${var.builder_vcenter_password} ${var.vm_name}"]
  }
}
