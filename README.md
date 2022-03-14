# Potential Terraform Bug During Subsequent Imports

This bug manifests itself when you have a configuration that references something created using `for_each` that is created outside of Terraform and then imported.

# Steps to Reproduce

1. Clone repo.
1. Stage relevant resources from `data.tf` into tenant. (Note: You could likely change these to actual resources in the configuration instead.):
   - vnet resource group
   - vnet
   - subnet
1. Change `subscription_id` in `providers.tf`.
1. Run `az login`.
1. Leave commented sections in `main.tf` commented, and run `terraform apply`. This should succeed in creating resources.
1. **OUTSIDE OF TERRAFORM**, create the public IP address resources per the commented configuration.
1. Uncomment lines 17-23 and line 37 in `main.tf`: `resource "azurerm_public_ip" "this" ...` block (17-23) and ` public_ip_address_id = azurerm_public_ip.this[each.key].id` line (37).
1. Run `terraform apply`. This will fail with the predicted error message that a resource exists and needs to be imported.
1. Import the first public IP resource with `terraform import 'azurerm_public_ip.this[\"vm1\"]' "/subscriptions/***/resourceGroups/rg-import-bug-test/providers/Microsoft.Network/publicIPAddresses/vm1-pip"`. This should succeed.
1. Attempt to import the second public IP resource with `terraform import 'azurerm_public_ip.this[\"vm2\"]' "/subscriptions/***/resourceGroups/rg-import-bug-test/providers/Microsoft.Network/publicIPAddresses/vm2-pip"`. This will fail with the following error:
   ```pwsh
    Error: Invalid index
   │
   │   on C:\Dev\terraform\azure\import-bug\main.tf line 37, in module "vms":
   │   37:       public_ip_address_id = azurerm_public_ip.this[each.key].id
   │     ├────────────────
   │     │ azurerm_public_ip.this is object with 1 attribute "vm1"
   │     │ each.key is "vm2"
   │
   │ The given key does not identify an element in this collection value.
   ```
1. Re-comment line 37: `public_ip_address_id = azurerm_public_ip.this[each.key].id`.
1. Attempt to import the second public IP again. This should now succeed.
1. Un-comment line 37.
1. Run `terraform apply` and it should succeed.
