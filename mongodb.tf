data "template_file" "mongo" {
  template = "${./service_configuration.json}"
  
}

data "mongodbatlas_clusters" "clusters" {
    project_id = var.mongdbatlas_project_id
}

data  "mongodbatlas_cluster" "cluster" {
  for_each = toset(data.mongodbatlas_clusters.cluster1.results[*].name)
  project_id = var.mongdbatlas_project_id
  name       = each.value
  

  connection_strings = {
    for servicename in var.service_configuration :
    "mongodb+srv://""${mongodbatlas_database_user.dbuser}":"${random_password.store-service-password}"@"${mongodbatlas_cluster.cluster.name}"/"${each.value.mongoDatabase}"/"${roles.value}"
  }
}

resource "random_password" "store-service-password" {
  length           = 20
  special          = true
  override_special = "******"
}

resource "mongodbatlas_database_user" "dbuser" {
  username           = "${var.environment}-${each.key}" 
  password           = random_password.store-service-password
  project_id         = "<PROJECT-ID>"
  auth_database_name = "admin"

  dynamic roles {
  for_each = each.value.mongoCollection[*]
    content {
      role_name       = "read"
      database_name   = each.value.mongoDatabase
      collection_name = roles.value
    }
  }
}
