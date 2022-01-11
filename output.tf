output "db config" {
  value = "${mongodbatlas_cluster.cluster.connection_strings}"
}
