terraform {
  # we should be okay with any version greater than 1, but expect 2.0 to be breaking
  required_version = ">= 1.0, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.99"
    }
  }
}
