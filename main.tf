terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.0.1"
    }
  }


  backend "azurerm" {
    resource_group_name   = "rg-terraform-backend"   # Name of the resource group
    storage_account_name  = "tfstatebackend123"      # Storage account (must be globally unique)
    container_name        = "tfstate"                # Blob container inside the storage account
    key                   = "jenkins-aks.tfstate"    # Name of the state file
  }
}



provider "azurerm" {
  # Configuration options
features {}

subscription_id = "a82477ec-edf0-442b-a92d-f2af6977fe64"

}



resource "azurerm_resource_group" "platform" {
  name     = "rg-jenkins-aks-prod"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "platform" {
  name                = "aks-jenkins-prod"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  dns_prefix          = "jenkinsaksprod"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  node_provisioning_profile {
    mode = "Auto"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.platform.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.platform.kube_config_raw

  sensitive = true
}