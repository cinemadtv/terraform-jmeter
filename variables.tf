variable "cluster_name" {
    description = "Cluster name"
    default = "jmeter"
}

variable "slave_count" {
    description = "Number of slaves"
    default = 3
}

variable "slave_size" {
    description = "Size of slaves"
    default = "Standard_B1ms"
}

variable "master_size" {
    description = "Size of master"
    default = "Standard_B1ms"
}

variable "region" {
    description = "Region"
    default = "Central US"
}
