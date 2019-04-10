variable "do_token" {
    description = "Digital Ocean API key"
    type = "string"
}
variable "admin_key_id" {
    description = "ID of ssh-key for root user"
    type = "string"
}
variable "domain_name" {
    description = "TLD for droplet. The login server will be login.${DOMAIN_NAME}"
    type = "string"
}

variable "do_user_data" {
  description = "user_data to configure cloud_init"
}


provider "digitalocean" {
    token = "${var.do_token}"
}

resource "digitalocean_droplet" "login_server" {
    name = "login.${var.domain_name}"
    size = "s-1vcpu-1gb"
    image = "centos-7-x64"
    region = "nyc1"
    ssh_keys = ["${var.admin_key_id}"]
    user_data = "${var.do_user_data}"
    provisioner "salt-masterless" {
        "local_state_tree" = "../salt"
        "local_pillar_roots" = "../pillar"
        "remote_pillar_roots" = "/srv/pillar"
        "remote_state_tree" = "/srv/salt"
    }
}

output "ipv4_address" {
    value = "${digitalocean_droplet.login_server.ipv4_address}"
}

