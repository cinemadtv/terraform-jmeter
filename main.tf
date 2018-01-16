provider "azurerm" {
  subscription_id = "44fbe376-73e5-4254-b0e4-8907fa31eaf1"
  client_id       = "757efb9a-66ba-4669-9aa2-c1b0368d726a"
  client_secret   = "1f7e0aa4-209f-4a03-aa2c-16cb7532a6a3"
  tenant_id       = "be7194e4-0334-4b3c-bafe-516bf53cdbd0"
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
  domain_name_label = "cinemadjmeter${count.index}"
}
