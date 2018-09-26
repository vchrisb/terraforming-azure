resource "random_id" "sb_db_password" {
  byte_length = 32
}

resource "azurerm_sql_server" "sbsql" {
    name = "${var.env_short_name}-sb-mssql-server"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
    version = "12.0"
    administrator_login = "mssqladmin"
    administrator_login_password = "${random_id.sb_db_password.b64}"
}

resource "azurerm_sql_database" "sbsql-db" {
  name                = "sbdb"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
    server_name = "${azurerm_sql_server.sbsql.name}"

}

resource "azurerm_sql_virtual_network_rule" "sb-sqlvnet-pas" {
  name                = "${var.env_short_name}-sbsql-pas-vnet-rule"
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  server_name         = "${azurerm_sql_server.sbsql.name}"
  subnet_id           = "${azurerm_subnet.pas_subnet.id}"
  depends_on           = ["azurerm_subnet.pas_subnet"]
}

resource "azurerm_sql_virtual_network_rule" "sb-sqlvnet-infrastructure" {
  name                = "${var.env_short_name}-sbsql-infra-vnet-rule"
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  server_name         = "${azurerm_sql_server.sbsql.name}"
  subnet_id           = "${azurerm_subnet.infrastructure_subnet.id}"
  depends_on           = ["azurerm_subnet.infrastructure_subnet"]
}

