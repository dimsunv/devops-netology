output "name" {
  value = "${var.name}"
}

output "nodes_ip" {
  value = yandex_compute_instance.instance.*.network_interface.0.nat_ip_address
}
