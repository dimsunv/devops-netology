output "network_id" {
  description = "The ID of the VPC"
  value       = yandex_vpc_network.this.id
}

output "subnet_ids" {
  value = [for subnet in yandex_vpc_subnet.this : subnet.id]
}

output "subnet_zones" {
  value = [for subnet in yandex_vpc_subnet.this : subnet.zone]
}

output "subnets" {
  value = { for v in yandex_vpc_subnet.this : v.zone => tomap({
    "id" = v.id,
    "name" = v.name,
    "zone" = v.zone
  }
  ) }
}
