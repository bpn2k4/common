terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://xxx:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = "xxx"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "vm_xxx" {
  name        = "vm-xxx"
  target_node = "xxx"
  vmid        = xxx
  full_clone  = true
  clone       = "ubuntu-22-04-template"
  onboot      = true

  memory    = 32768
  sockets   = 1
  cores     = 8
  vcpus     = 8
  ipconfig0 = "ip=xxx.xxx.xxx.xxx/xx,gw=xxx.xxx.xxx.1"

  ciuser     = "ubuntu"
  cipassword = "1"
  sshkeys    = file("../../key/public.key")

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    type    = "virtio"
    storage = "local-lvm"
    size    = "200G"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 15",
      "sudo rm -rf /etc/ssh/sshd_config.d/*",
      "sudo bash -c \"echo 'PasswordAuthentication yes' > /etc/ssh/sshd_config.d/setting.conf\"",
      "sudo sed -i 's/- set_hostname//g' /etc/cloud/cloud.cfg",
      "sudo sed -i 's/- update_hostname//g' /etc/cloud/cloud.cfg",
      "sudo sed -i 's/- update_etc_hosts//g' /etc/cloud/cloud.cfg",
      "sudo sed -i 's/preserve_hostname: false/preserve_hostname: true/g' /etc/cloud/cloud.cfg",
      "sudo reboot"
    ]
    connection {
      type        = "ssh"
      host        = "<host>"
      private_key = file("../../key/private.key")
      user        = "ubuntu"
    }
    on_failure = continue
  }
}

