variable "subscription_id" {
  description = "Azure subscription id"
}
variable "client_id" {
  description = "Azure client id"
}
variable "client_secret" {
  description = "Azure client secret"
}
variable "tenant_id" {
  description = "Azure tenant id"
}

variable "cluster_name" {
    description = "Cluster name"
    default = "jmeter"
}

variable "public_key" {
    description = "SSH Public Key"
    default = ".ssh/jmeter.pub"
}

variable "private_key" {
    description = "SSH Private Key"
    default = ".ssh/jmeter"
}


variable "admin_username" {
    description = "Admin username"
    default = "admin"
}

variable "slave_count" {
    description = "Number of slaves"
    default = 3
}

variable "slave_size" {
    description = "Size of slaves"
    default = "Standard_D2s_v3"
}

variable "master_size" {
    description = "Size of master"
    default = "Standard_B1ms"
}

variable "region" {
    description = "Region"
    default = "centralus"
}
