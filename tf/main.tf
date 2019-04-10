variable "do_token" {}
variable "admin_public_key" {}

variable "domain_name" {}

variable "do_user_data" {
    description = "Cloud-config user data."
    default =<<EOF
#cloud-config

manage_etc_hosts: false
EOF
}

variable "user_workstations" {
    default = "0"
}

provider "digitalocean" {
    token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "admin_key" {
    name = "admin_key"
    public_key = "${var.admin_public_key}"
}
resource "digitalocean_domain" "default" {
  name       = "${var.domain_name}"
}
module "workstations" {
  source = "./modules/workstations"
  do_token = "${var.do_token}"
  user_workstations = "${var.user_workstations}"
  admin_key_id = "${digitalocean_ssh_key.admin_key.id}"
  domain_name = "${var.domain_name}"
  do_user_data = "${var.do_user_data}"
}

module "login_server" {
  source = "./modules/login_server"
  do_token = "${var.do_token}"
  admin_key_id = "${digitalocean_ssh_key.admin_key.id}"
  domain_name = "${var.domain_name}"
  do_user_data = "${var.do_user_data}"
}
resource "digitalocean_record" "login_server" {
    domain = "${digitalocean_domain.default.name}"
    name   = "login"
    type   = "A"
    value  = "${module.login_server.ipv4_address}"
}

resource "digitalocean_record" "krb_server" {
    domain = "${digitalocean_domain.default.name}"
    name   = "krb"
    type   = "CNAME"
    value  = "${digitalocean_record.login_server.fqdn}."
}