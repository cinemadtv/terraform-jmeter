provider "azurerm" { }

resource "azurerm_resource_group" "jmeter" {
  name     = "${var.cluster_name}"
  location = "${var.region}"
}

resource "azurerm_virtual_network" "jmeter" {
  name                = "${var.cluster_name}-vn"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.jmeter.location}"
  resource_group_name = "${azurerm_resource_group.jmeter.name}"
}

resource "azurerm_subnet" "jmeter" {
  name                 = "${var.cluster_name}-sub"
  resource_group_name  = "${azurerm_resource_group.jmeter.name}"
  virtual_network_name = "${azurerm_virtual_network.jmeter.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "jmeter" {
  name                         = "${var.cluster_name}-public-lb"
  location                     = "${azurerm_resource_group.jmeter.location}"
  resource_group_name          = "${azurerm_resource_group.jmeter.name}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_lb" "jmeter" {
  name                = "${var.cluster_name}-lb"
  location            = "${azurerm_resource_group.jmeter.location}"
  resource_group_name = "${azurerm_resource_group.jmeter.name}"

  frontend_ip_configuration {
    name                 = "${var.cluster_name}-public-ip"
    public_ip_address_id = "${azurerm_public_ip.jmeter.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "jmeter" {
  resource_group_name = "${azurerm_resource_group.jmeter.name}"
  loadbalancer_id     = "${azurerm_lb.jmeter.id}"
  name                = "${var.cluster_name}-backend-pool"
}

