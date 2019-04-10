variable "do_token" {}
variable "user_workstations" {}
variable "admin_key_id" {}
variable "domain_name" {}

variable "do_user_data" {
  description = "user_data to configure cloud_init"
}


provider "digitalocean" {
    token = "${var.do_token}"
}

resource "digitalocean_droplet" "workstation" {
    count = "${var.user_workstations}"
    name = "workstation-${count.index}"
    size = "s-1vcpu-1gb"
    image = "centos-7-x64"
    region = "nyc1"
    ssh_keys = ["${var.admin_key_id}"]
    user_data ="${var.do_user_data}"
}
