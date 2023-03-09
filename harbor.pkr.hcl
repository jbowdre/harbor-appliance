packer {
  required_version                    = ">= 1.6.3"
  required_plugins {
    vsphere = {
      version                         = ">= 1.0.8"
      source                          = "github.com/hashicorp/vsphere"
    }
    sshkey = {
      version                         = "1.0.3"
      source                          = "github.com/ivoronin/sshkey"
    }
  }
}

// Dyanmically-generated SSH key for the install
data "sshkey" "install" {
  type                                = "ed25519"
  name                                = "packer_key"
}

locals {
  build_date                          = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_description                   = "Harbor version ${var.harbor_version}\nBuild date: ${local.build_date}\nBuild tool: ${local.build_tool}"
  build_tool                          = "HashiCorp Packer ${packer.version}"
  ssh_private_key_file                = data.sshkey.install.private_key_path
  ssh_public_key                      = data.sshkey.install.public_key
  data_source_content = {
    "/ks.json" = templatefile("${abspath(path.root)}/data/ks.pkrtpl.hcl", {
      guest_hostname                  = var.vm_name
      guest_root_ssh_key              = local.ssh_public_key
      guest_part_boot                 = var.guest_part_boot
      guest_part_docker               = var.guest_part_docker
      guest_part_log                  = var.guest_part_log
      guest_part_root                 = var.guest_part_root
      guest_part_swap                 = var.guest_part_swap
      guest_part_tmp                  = var.guest_part_tmp
      guest_part_var                  = var.guest_part_var
      guest_root_password             = var.guest_root_password
      package_list                    = var.package_list
    })
  }
}

source "vsphere-iso" "harbor" {

  # vsphere connection
  vcenter_server                      = var.vsphere_endpoint
  username                            = var.vsphere_username
  password                            = var.vsphere_password
  insecure_connection                 = var.vsphere_insecure_connection

  # placement
  cluster                             = var.vsphere_cluster
  host                                = var.vsphere_host
  datastore                           = var.vsphere_datastore
  datacenter                          = var.vsphere_datacenter
  folder                              = var.vsphere_folder

  # vm properties
  cdrom_type                          = var.vm_cdrom_type
  CPU_hot_plug                        = var.vm_cpu_hotplug
  CPUs                                = var.vm_cpu_count
  disk_controller_type                = var.vm_disk_controller_type
  firmware                            = var.vm_firmware
  guest_os_type                       = var.vm_guest_os_type
  notes                               = local.build_description
  RAM                                 = var.vm_mem_size
  RAM_hot_plug                        = var.vm_mem_hotplug
  remove_cdrom                        = var.remove_cdrom
  tools_upgrade_policy                = var.vm_tools_upgrade_policy
  vm_name                             = var.vm_name
  vm_version                          = var.vm_version
  configuration_parameters = {
    "devices.hotplug"                 = "FALSE"
  }
  network_adapters {
    network                           = var.vsphere_network
    network_card                      = var.vm_network_card
  }
  storage {
    disk_size                         = var.vm_disk_size
    disk_thin_provisioned             = var.vm_disk_thin_provisioned
  }

  # boot properties
  boot_command                        = var.boot_command
  boot_wait                           = var.boot_wait
  cd_content                          = local.data_source_content
  cd_label                            = var.cd_label
  iso_checksum                        = var.iso_checksum
  iso_url                             = var.iso_url

  # guest connection
  communicator                        = "ssh"
  shutdown_command                    = var.shutdown_command
  shutdown_timeout                    = var.shutdown_timeout
  ssh_clear_authorized_keys           = var.remove_keys
  ssh_port                            = 22
  ssh_private_key_file                = local.ssh_private_key_file
  ssh_username                        = "root"

  # export
  export {
    force                             = true
    output_directory                  = "./output-vsphere-iso/"
  }
}

build {
  sources                             = ["source.vsphere-iso.harbor"]

  provisioner "shell" {
    env                       = {
      "DOCKER_COMPOSE_VERSION"        = var.harbor_compose_version
      "HARBOR_VERSION"                = var.harbor_version
    }
    execute_command                   = "{{ .Vars }} bash {{ .Path }}"
    scripts                           = ["scripts/photon-settings.sh"]
  }

  provisioner "shell" {
    expect_disconnect                 = true
    scripts                           = ["scripts/photon-docker.sh"]
  }

  provisioner "shell" {
    pause_before                      = "20s"
    scripts                           = ["scripts/photon-cleanup.sh"]
  }

  provisioner "file" {
    destination                       = "/etc/rc.d/rc.local"
    source                            = "files/rc.local"
  }

  provisioner "file" {
    destination                       = "/opt/harbor/setup/getOvfProperty.py"
    source                            = "files/getOvfProperty.py"
  }

  provisioner "file" {
    destination                       = "/opt/harbor/setup/setup.sh"
    source                            = "files/setup.sh"
  }

  provisioner "file" {
    destination                       = "/opt/harbor/setup/setup-01-os.sh"
    source                            = "files/setup-01-os.sh"
  }

  provisioner "file" {
    destination                       = "/opt/harbor/setup/setup-02-network.sh"
    source                            = "files/setup-02-network.sh"
  }

  provisioner "file" {
    destination                       = "/opt/harbor/setup/setup-03-harbor.sh"
    source                            = "files/setup-03-harbor.sh"
  }

  post-processor "shell-local" {
    environment_vars                  = [
      "APPLIANCE_ADMIN_USER=${var.appliance_def_admin_user}",
      "APPLIANCE_DNS=${var.appliance_def_dns}",
      "APPLIANCE_DOMAIN=${var.appliance_def_domain}",
      "APPLIANCE_GATEWAY=${var.appliance_def_gateway}",
      "APPLIANCE_HOSTNAME=${var.appliance_def_hostname}",
      "APPLIANCE_IP=${var.appliance_def_ip}",
      "APPLIANCE_NTP=${var.appliance_def_ntp}",
      "APPLIANCE_PRODUCT_URL=${var.appliance_product_url}",
      "APPLIANCE_PRODUCT=${var.appliance_product}",
      "APPLIANCE_VENDOR_URL=${var.appliance_vendor_url}",
      "APPLIANCE_VENDOR=${var.appliance_vendor}",
      "DOCKER_COMPOSE_VERSION=${var.harbor_compose_version}",
      "FINAL_PHOTON_APPLIANCE_NAME=${var.vm_name}",
      "HARBOR_VERSION=${var.harbor_version}",
      "PHOTON_APPLIANCE_NAME=${var.vm_name}",
      "PHOTON_OVF_TEMPLATE=${var.harbor_ovf_template}"
    ]
    inline                            = ["cd manual", "./add_ovf_properties.sh"]
  }

  post-processor "shell-local" {
    inline                            = ["pwsh -F unregister_vm.ps1 ${var.vsphere_endpoint} ${var.vsphere_username} ${var.vsphere_password} ${var.vm_name}"]
  }
}
