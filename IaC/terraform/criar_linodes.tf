# Autor: Fábio Sartori
# Copyright: 20220311

terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.26.1"
    }
  }
}

provider "linode" {
    token = var.shared_token
}

resource "linode_instance" "kalipi" {
    label = var.kali_label
    image = var.kali_image
    type = var.kali_type
    region = var.shared_region
    root_pass = var.shared_root_pass
    private_ip = var.shared_private_ip
    tags = var.kali_tags
}

resource "linode_instance" "centospi" {
    label = var.centos_label
    image = var.centos_image
    type = var.centos_type
    region = var.shared_region
    root_pass = var.shared_root_pass
    private_ip = var.shared_private_ip
    tags = var.kali_tags
}


variable "shared_token" {}
    variable "region" {
    default = "us-central"
}
variable "shared_root_pass" {}
variable "shared_private_ip" {}
variable "shared_region" {}
variable "kali_tags" {}
variable "kali_label" {}
variable "kali_image" {}
variable "kali_type" {}
variable "centos_tags" {}
variable "centos_label" {}
variable "centos_image" {}
variable "centos_type" {}