provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

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
  count                        = "${var.slave_count+1}"
  name                         = "${var.cluster_name}-ip-${count.index}"
  location                     = "${azurerm_resource_group.jmeter.location}"
  resource_group_name          = "${azurerm_resource_group.jmeter.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "${var.cluster_name}${count.index}"
}


output "run_user" {
  # use slave count, since elements are 0-based index
  value = "${admin_username}"
}
