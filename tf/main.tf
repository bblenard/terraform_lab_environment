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

resource "digitalocean_droplet" "workstation" {
    count = "${var.user_workstations}"
    name = "workstation-${count.index}"
    size = "s-1vcpu-1gb"
    image = "centos-7-x64"
    region = "nyc1"
    ssh_keys = ["${digitalocean_ssh_key.admin_key.id}"]
    user_data ="${var.do_user_data}"
}

resource "digitalocean_droplet" "ldap_server" {
    name = "ldap.${var.domain_name}"
    size = "s-1vcpu-1gb"
    image = "centos-7-x64"
    region = "nyc1"
    ssh_keys = ["${digitalocean_ssh_key.admin_key.id}"]
    user_data = "${var.do_user_data}"
    provisioner "salt-masterless" {
        "local_state_tree" = "../salt"
        "local_pillar_roots" = "../pillar"
        "remote_pillar_roots" = "/srv/pillar"
        "remote_state_tree" = "/srv/salt"
    }
}

resource "digitalocean_droplet" "kerberos_server" {
    name = "krb.${var.domain_name}"
    size = "s-1vcpu-1gb"
    image = "centos-7-x64"
    region = "nyc1"
    ssh_keys = ["${digitalocean_ssh_key.admin_key.id}"]
    user_data = "${var.do_user_data}"
    provisioner "salt-masterless" {
        "local_state_tree" = "../salt"
        "local_pillar_roots" = "../pillar"
        "remote_pillar_roots" = "/srv/pillar"
        "remote_state_tree" = "/srv/salt"
    }
}

resource "digitalocean_record" "ldap_server" {
    domain = "${digitalocean_domain.default.name}"
    name   = "ldap"
    type   = "A"
    value  = "${digitalocean_droplet.ldap_server.ipv4_address}"
}

resource "digitalocean_record" "krb_server" {
    domain = "${digitalocean_domain.default.name}"
    name   = "krb"
    type   = "A"
    value  = "${digitalocean_droplet.kerberos_server.ipv4_address}"
}
