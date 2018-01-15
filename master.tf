resource "azurerm_network_interface" "jmeter_master" {
  name                = "${var.cluster_name}-master-ni"
  location            = "${azurerm_resource_group.jmeter.location}"
  resource_group_name = "${azurerm_resource_group.jmeter.name}"

  ip_configuration {
    name                          = "${var.cluster_name}-master-configuration"
    subnet_id                     = "${azurerm_subnet.jmeter.id}"
    private_ip_address_allocation = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.jmeter.id}"]
  }
}

resource "azurerm_managed_disk" "master_md" {
  name                 = "${var.cluster_name}-master-datadisk"
  location             = "${azurerm_resource_group.jmeter.location}"
  resource_group_name  = "${azurerm_resource_group.jmeter.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_availability_set" "master_avset" {
  name                         = "${var.cluster_name}-master-avset"
  location                     = "${azurerm_resource_group.jmeter.location}"
  resource_group_name          = "${azurerm_resource_group.jmeter.name}"
  managed                      = true
}

resource "azurerm_virtual_machine" "master_jmeter" {
  name                  = "${var.cluster_name}-master-vm"
  location              = "${azurerm_resource_group.jmeter.location}"
  availability_set_id   = "${azurerm_availability_set.master_avset.id}"
  resource_group_name   = "${azurerm_resource_group.jmeter.name}"
  network_interface_ids = ["${azurerm_network_interface.jmeter_master.id}"]
  vm_size               = "${var.master_size}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.cluster_name}-master-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.cluster_name}-master"
    admin_username = "cinemadtv"
    admin_password = "quBHD_fc2nm%4M"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "testing"
  }

  provisioner "remote-exec" {
    script = "resources/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sed -i -e 's/remote_hosts=.*/remote_hosts=${join(",", azurerm_network_interface.jmeter_master.*.private_ip_address)}/g' /opt/jmeter/bin/jmeter.properties",
      "sed -i -e '/127.0.1.1.*/d' /etc/hosts"
    ]
  }
}

output "master_address" {
  value = "${azurerm_network_interface.jmeter_master.private_ip_address}"
}
