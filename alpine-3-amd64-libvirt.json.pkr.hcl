variable "headless" {
  type    = bool
  default = false
}

variable "version" {
  type    = string
  default = "2"
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "iso_checksum" {
  type    = string
  default = "${env("iso_checksum")}"
}

variable "iso_url" {
  type    = string
  default = "${env("iso_url")}"
}

variable "ram" {
  type    = string
  default = "2048"
}

variable "disk_size" {
  type    = string
  default = "${env("disk_size")}"
}

variable "ssh_password" {
  type    = string
  default = "${env("root_password")}"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "template_description" {
  type    = string
  default = "Alpine Linux 3.11 x86_64 template built with packer"
}

variable "vm_memory" {
  type    = string
  default = "1024"
}

source "qemu" "alpine" {
  accelerator      = "kvm"
  boot_command     = ["<wait25>root<enter><wait4>", 
    "setup-alpine<enter><wait8>",
    "<enter><wait4>",
    "alpine-tf<enter><wait4><enter><wait4>",
    "dhcp<enter>",
    "<wait5>n<enter><wait5>",
    "${var.ssh_password}<enter><wait5>", "${var.ssh_password}<enter><wait>", "<wait5>", "<wait>", "Europe/Paris<enter><wait5><enter>r<enter>", "<wait5>", "no", "<enter>", "<enter>", "yes<enter><wait6>", "<enter><wait5>vda<enter>lvm<enter>sys<enter><wait2>y<enter><enter>reboot<enter>", "<wait70>", "root<enter><wait8>", "${var.ssh_password}<enter><wait5> ", "apk update && apk add curl<enter>", "mkdir -p ~/.ssh<enter>", "touch ~/.ssh/authorized_keys<enter><wait5>chmod 600 ~/.ssh/authorized_keys<enter><wait5>", "curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/authorized_keys >> ~/.ssh/authorized_keys<enter>", "echo ‘PermitRootLogin yes’ >> /etc/ssh/sshd_config <enter>", "<wait2>service sshd restart <enter> <wait2>", "curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/repositories > /etc/apk/repositories<enter>", "<wait>apk update <enter>", "apk add python3<enter><wait1>", "curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py<enter> <wait2>", "python3 /tmp/get-pip.py <enter> <wait2>", "apk add qemu-guest-agent<enter><wait3>", "rc-update add qemu-guest-agent<enter>", "service qemu-guest-agent start<enter>"]
  boot_wait        = "15s"
  disk_cache       = "none"
  disk_compression = true
  disk_discard     = "unmap"
  disk_interface   = "virtio"
  disk_size        = "${var.disk_size}"
  format           = "qcow2"
  headless         = "${var.headless}"
  http_directory   = "http"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.vm_memory}"
  net_device       = "virtio-net"
  output_directory = "artifacts/qemu/${var.version}"
  qemu_binary      = "/usr/bin/qemu-system-x86_64"
  qemuargs         = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"]]
  shutdown_command = "poweroff"
  ssh_password     = "${var.ssh_password}"
  ssh_timeout      = "15m"
  ssh_username     = "${var.ssh_username}"
}

build {
  description = "Build Alpine Linux 3 x86_64 Proxmox template"

  sources = ["source.qemu.alpine"]

  provisioner "ansible" {
    ansible_env_vars = ["ANSIBLE_FORCE_COLOR=True"]
    playbook_file    = "./playbook/provisioning.yml"
  }

}
