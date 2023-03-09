{
  "hostname": "${ guest_hostname }",
  "password": {
    "crypted": false,
    "text": "${ guest_root_password }"
  },
  "disk": "/dev/sda",
  "partitions": [
    {
      "mountpoint": "/",
      "size": ${ guest_part_root },
      "filesystem": "ext4",
      "lvm": {
        "vg_name": "sysvg",
        "lv_name": "lv_root"
      }
    },
    {
      "mountpoint": "/boot",
      "size": ${ guest_part_boot },
      "filesystem": "ext4"
    },
    {
      "mountpoint": "/tmp",
      "size": ${ guest_part_tmp},
      "filesystem": "ext4",
      "lvm": {
        "vg_name": "sysvg",
        "lv_name": "lv_tmp"
      }
    },
    {
      "mountpoint": "/var",
      "size": ${ guest_part_var },
      "filesystem": "ext4",
      "lvm": {
        "vg_name": "sysvg",
        "lv_name": "lv_var"
      }
    },
    {
      "mountpoint": "/var/log",
      "size": ${ guest_part_log },
      "filesystem": "ext4",
      "lvm": {
        "vg_name": "sysvg",
        "lv_name": "lv_log"
      }
    },
    {
      "mountpoint": "/var/lib/docker",
      "size": ${ guest_part_docker },
      "filesystem": "ext4",
      "lvm": {
        "vg_name": "sysvg",
        "lv_name": "lv_docker"
      }
    },
    {
      "size": ${ guest_part_swap },
      "filesystem": "swap"
    }
  ],
  "packages": [
%{ for package in package_list ~}
    "${ package }",
%{ endfor ~}
    "minimal"
  ],
  "postinstall": [
    "#!/bin/sh",
    "chage -I -1 -m 0 -M 99999 -E -1 root",
    "mkdir -p /root/.ssh",
    "echo \"${ guest_root_ssh_key }\" >> /root/.ssh/authorized_keys",
    "sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config",
    "sed -i 's/MaxAuthTries.*/MaxAuthTries 10/g' /etc/ssh/sshd_config",
    "systemctl restart sshd.service"
  ],
  "linux_flavor": "linux",
  "network": {
    "type": "dhcp"
  }
}
