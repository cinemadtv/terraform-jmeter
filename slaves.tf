resource "azurerm_network_interface" "jmeter_slave" {
  count               = "${var.slave_count}"
  name                = "${var.cluster_name}-slave-ni-${count.index}"
  location            = "${azurerm_resource_group.jmeter.location}"
  resource_group_name = "${azurerm_resource_group.jmeter.name}"

  ip_configuration {
    name                          = "${var.cluster_name}-configuration"
    subnet_id                     = "${azurerm_subnet.jmeter.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.jmeter.*.id, count.index)}"
  }
}

resource "azurerm_managed_disk" "slave_md" {
  count                = "${var.slave_count}"
  name                 = "${var.cluster_name}-slave-datadisk-${count.index}"
  location             = "${azurerm_resource_group.jmeter.location}"
  resource_group_name  = "${azurerm_resource_group.jmeter.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_virtual_machine" "slave_jmeter" {
  count                 = "${var.slave_count}"
  name                  = "${var.cluster_name}-slave-vm-${count.index}"
  location              = "${azurerm_resource_group.jmeter.location}"
  resource_group_name   = "${azurerm_resource_group.jmeter.name}"
  network_interface_ids = ["${element(azurerm_network_interface.jmeter_slave.*.id, count.index)}"]
  vm_size               = "${var.slave_size}"

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
    name              = "${var.cluster_name}-slave-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.cluster_name}-slave-${count.index}"
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
    host = "${var.cluster_name}${count.index}.${var.region}.cloudapp.azure.com"
    user = "${var.admin_username}"
    private_key = "${file(var.private_key)}"
    timeout = "2m"
    agent = false
  }

  provisioner "remote-exec" {
    script = "resources/install.sh"
  }

  provisioner "file" {
    source = "resources/init"
    destination = "/home/${var.admin_username}/jmeter"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/${var.admin_username}/jmeter /etc/init.d/jmeter",
      "sudo sed -i -e 's/JMETER_IP=.*/JMETER_IP=${element(azurerm_network_interface.jmeter_slave.*.private_ip_address, count.index)}/g' /etc/init.d/jmeter",
      "sudo chmod +x /etc/init.d/jmeter",
      "sudo update-rc.d jmeter defaults",
      "sudo /etc/init.d/jmeter start",
      "sleep 2" # see http://stackoverflow.com/questions/36207752/how-can-i-start-a-remote-service-using-terraform-provisioning
    ]
  }
}

output "slave_addresses" {
  value = ["${azurerm_network_interface.jmeter_slave.*.private_ip_address}"]
}
