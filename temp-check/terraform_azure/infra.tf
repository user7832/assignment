resource "azurerm_resource_group" "rg" {
  name = "monitoring_rg"
  location = var.location
  tags = {
    app = "prom-temp"
  }
}

resource "azurerm_virtual_network" "monitoring_network" {
    name                = "monitoring_network"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        app = "prom-temp"
    }
}

resource "azurerm_subnet" "monitoring_subnet" {
    name                 = "monitoring_subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.monitoring_network.name
    address_prefixes     = ["10.0.2.0/24"]

    tags = {
        app = "prom-temp"
    }
}

resource "azurerm_public_ip" "monitoring_ip" {
    name                         = "monitoring_ip"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"

    tags = {
        app = "prom-temp"
    }
}

resource "azurerm_network_security_group" "monitoring_sg" {
    name                = "monitoring_sg"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Prometheus"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9090"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Grafana"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3000"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        app = "prom-temp"
    }
}

resource "azurerm_network_interface" "monitoring_nic" {
    name                        = "monitoring_nic"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "monitoring_nic_config"
        subnet_id                     = azurerm_subnet.monitoring_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.monitoring_ip.id
    }

    tags = {
        app = "prom-temp"
    }
}

resource "azurerm_network_interface_security_group_association" "monitoring_nic_sg_association" {
    network_interface_id      = azurerm_network_interface.monitoring_nic.id
    network_security_group_id = azurerm_network_security_group.monitoring_sg.id
}

resource "tls_private_key" "mon_srv_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "monitoring_server" {
  name                = "monitoring-server"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_F2"

  network_interface_ids = [azurerm_network_interface.monitoring_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  computer_name  = "monitoring-server"
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username       = "azureuser"
    public_key     = tls_private_key.mon_srv_ssh_key.public_key_openssh
  }

  custom_data = templatefile(
    "../userdata.sh.tmpl",
    {
      we_apikey = var.we_apikey,
      we_city = var.we_city
    }
  )

  tags = {
      app = "prom-temp"
  }
}

output "tls_private_key" {
    value = tls_private_key.mon_srv_ssh_key.private_key_pem
}
output "grafana_url" {
    value = "http://${azurerm_linux_virtual_machine.monitoring_server.public_ip_address}:3000"
}
