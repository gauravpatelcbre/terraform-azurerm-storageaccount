output "sgact" {
  value = azurerm_storage_account.sg_act
}


output "sgact_container" {
  value = azurerm_storage_container.container
}


output "sgact_fileshare" {
  description = "The 'azurerm_storage_container.fileshare' resource."
  value       = azurerm_storage_share.share
}