resource "azurerm_network_interface" "jmeter_master" {
  name                = "${var.cluster_name}-master-ni"
  location            = "${azurerm_resource_group.jmeter.location}"
  resource_group_name = "${azurerm_resource_group.jmeter.name}"

  ip_configuration {
    name                          = "${var.cluster_name}-master-configuration"
    subnet_id                     = "${azurerm_subnet.jmeter.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.jmeter.*.id, var.slave_count)}"
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


resource "azurerm_virtual_machine" "master_jmeter" {
  name                  = "${var.cluster_name}-master-vm"
  location              = "${azurerm_resource_group.jmeter.location}"
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
    admin_username = "${var.admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys = [{
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file(var.public_key)}"
    }]
  }

  tags {
    environment = "testing"
  }

  connection {
    type = "ssh"
    # use slave count, since elements are 0-based index
    host = "cinemadjmeter${var.slave_count}.${var.region}.cloudapp.azure.com"
    user = "${var.admin_username}"
    private_key = "${file(var.private_key)}"
    timeout = "2m"
    agent = false
  }

  provisioner "remote-exec" {
    script = "resources/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i -e 's/remote_hosts=.*/remote_hosts=${join(",", azurerm_network_interface.jmeter_slave.*.private_ip_address)}/g' /opt/jmeter/bin/jmeter.properties",
      "sudo sed -i -e '/127.0.1.1.*/d' /etc/hosts"
    ]
  }
}

output "master_address" {
  # use slave count, since elements are 0-based index
  value = "${var.cluster_name}${var.slave_count}.${var.region}.cloudapp.azure.com"
}
