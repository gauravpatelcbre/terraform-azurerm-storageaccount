data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name == null ? "${local.vnet_prefix}-private" : var.vnet_name
  resource_group_name  = var.vnet_rg_name
}


resource "azurerm_storage_account" "sg_act" {
  name                            = var.sa_name
  resource_group_name             = var.rg_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  enable_https_traffic_only       = false
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.allowed_ips
    virtual_network_subnet_ids = var.allowed_subnets
    bypass = [
      "Metrics",
      "Logging",
      "AzureServices"
    ]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags


  dynamic "azure_files_authentication" {
    for_each = var.azure_files_authentication != null ? [1] : []

    content {
      directory_type = var.azure_files_authentication.directory_type

      active_directory {
        domain_guid         = var.azure_files_authentication.domain_guid
        domain_name         = var.azure_files_authentication.domain_name
        domain_sid          = var.azure_files_authentication.domain_sid
        forest_name         = var.azure_files_authentication.forest_name
        netbios_domain_name = var.azure_files_authentication.netbios_domain_name
        storage_sid         = var.azure_files_authentication.storage_sid
      }
    }
  }

  dynamic "blob_properties" {
    for_each = var.account_kind != "FileStorage" && var.blob_properties != null ? [1] : []

    content {
      versioning_enabled  = var.blob_properties.versioning_enabled
      change_feed_enabled = var.blob_properties.change_feed_enabled
    }
  }
}


resource "azurerm_private_endpoint" "pvt" {
  for_each = var.subresource_names

  depends_on = [
    azurerm_storage_account.sg_act
  ]

  name                = "${var.sa_name}-${each.key}-pvtlink"
  subnet_id           = data.azurerm_subnet.subnet.id
  resource_group_name = var.rg_name
  tags                = var.tags
  location            = var.location

  private_dns_zone_group {
    name                 = "${var.sa_name}-${each.key}-dns"
    private_dns_zone_ids = ["/subscriptions/9916d0f7-a2fd-48f2-b38b-d12e90ed9309/resourceGroups/networking-dns/providers/Microsoft.Network/privateDnsZones/privatelink.${each.key}.core.windows.net"]
  }

  private_service_connection {
    name                           = "${var.sa_name}-${each.key}-svclink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.sg_act.id
    subresource_names              = [each.key]
  }
}


resource "azurerm_storage_share" "share" {
  for_each = var.file_shares

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.sg_act.name
  quota                = each.value.quota
}


resource "azurerm_storage_container" "container" {
  count = length(var.containers)

  depends_on = [
    azurerm_storage_account.sg_act,
    azurerm_private_endpoint.pvt
  ]

  name                  = var.containers[element(keys(var.containers), count.index)].container_name
  storage_account_name  = azurerm_storage_account.sg_act.name
  container_access_type = var.containers[element(keys(var.containers), count.index)].container_access_type
}

/* resource "azurerm_storage_management_policy" "sg_act" {
  storage_account_id = azurerm_storage_account.sg_act.id

  rule {
    name    = "rule1"
    enabled = true
    filters {
      prefix_match = var.sg_act_management_policy_prefix_match
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 30
      }
      version {
        delete_after_days_since_creation = 30
      }
    }
  }
} */