variable "tags" {
  description = "Please reference the current tagging policy for required tags and allowed values.  See README for link to policy."
  type        = map(string)
}

variable "location" {
  description = "The location where the Azure resources should be created. For a list of all Azure locations, please consult the 'Azure Regions' link in the README or run 'az account list-locations --output table'."
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group in which to create the Azure resources."
  type        = string
}

variable "sa_name" {
  description = "The name to use for the storage account.  Must be lowercase, alphanumeric, globally unique and no longer than 24 chars."
  type        = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are 'Standard' and 'Premium'."
  type        = string
}

variable "account_kind" {
  description = "Defines the Kind of account. Valid options are 'Storage', 'StorageV2' and 'BlobStorage'."
  type        = string
  default     = "StorageV2"
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are 'LRS', 'GRS', 'RAGRS' and 'ZRS'."
  type        = string
}

variable "enable_https_traffic_only" {
  description = "Whether to only allow secure traffic.  See the 'Require secure transfer' link in the README for more info."
  type        = bool
  default     = true
}

variable "enable_azure_defender" {
  description = "Whether to enable Azure Defender, advanced threat protection subscription."
  type        = bool
  default     = true
}

variable "vnet_name" {
  description = "The name of the VNET to use for Private Link."
  type        = string
  #default     = "null"
}

variable "vnet_rg_name" {
  description = "The name of the Resource Group that contains the VNET."
  type        = string
  default     = "Networking"
}

variable "subnet_name" {
  description = "The Name of the subnet used for the private endpoint."
  type        = string
  default     = "PlatformServicesSubnet"
}

variable "subresource_names" {
  description = "A list of subresource names which the Private Endpoint is able to connect to. `subresource_names` corresponds to `group_id`. Changing this forces a new resource to be created. See `Private link resource` in Related Links for a list of subresources that are available."
  type        = set(string)
  default     = ["blob"]
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items within this Account to opt into being public."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The name of the Resource Group that contains the VNET."
  type        = string
  default     = "TLS1_2"
}

variable "allowed_ips" {
  description = "A list of IP addresses or CIDRs that are allowed to connect to this storage account."
  type        = list(string)
  default     = []
}

variable "allowed_subnets" {
  description = "A list of subnet ids that are allowed to connect to this storage account.  It is recommended to use the 'azurerm_subnet' terraform data source to feed this information."
  type        = set(string)
  default     = []
}

variable "azure_files_authentication" {
  description = "Configure Active Directory authentication with ADDS or AAD. See object specific arguments in the README."
  type = object({
    directory_type      = string
    domain_guid         = string
    domain_name         = string
    domain_sid          = string
    forest_name         = string
    netbios_domain_name = string
    storage_sid         = string
  })
  default = null
}

variable "file_shares" {
  description = "Map of file shares to create. See object specific arguments in the README."
  type = map(object({
    name  = string
    quota = number
  }))
  default = {}
}

variable "blob_properties" {
  description = "Configure blob properties. See object specific arguments in the README."
  type = object({
    versioning_enabled  = bool
    change_feed_enabled = bool
  })
  default = null
}

variable "containers" {
  description = "See object specific arguments in the README."
  type = map(object({
    container_name        = string
    container_access_type = string
  }))
  default = {}
}

locals {
  ###### region prefix calculation
  vnet_prefix = "${lower(var.tags.Environment)}${lookup(local.region_code, var.location, "null")}"

  region_code = {
    "South Central US"    = "ussc"
    "southcentralus"      = "ussc"
    "East US 2"           = "use2"
    "eastus2"             = "use2"
    "West US 2"           = "usw2"
    "westus2"             = "usw2"
    "UK South"            = "ukso"
    "uksouth"             = "ukso"
    "West Europe"         = "euwe"
    "westeurope"          = "euwe"
    "East Asia"           = "aphk"
    "eastasia"            = "aphk"
    "Australia East"      = "auea"
    "australiaeast"       = "auea"
    "Australia Southeast" = "ause"
    "australiasoutheast"  = "ause"
    "Southeast Asia"      = "apse"
    "southeastssia"       = "apse"
    "Central US"          = "usce"
  }
}
