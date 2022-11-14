resource "local_file" "ansible_inventory" {
  content = templatefile("template/inventory.tmpl",
    {
     ansible_group = local.ansible_inventory[terraform.workspace],

     clickhouse_host_name = module.clickhouse.name
     clickhouse_host_ip = module.clickhouse.nodes_ip

     lighthouse_host_name = module.lighthouse.name
     lighthouse_host_ip = module.lighthouse.nodes_ip

     server_host_name = module.server.name
     server_host_ip = module.server.nodes_ip
    }
  )
  filename = "../inventory/${local.ansible_inventory[terraform.workspace]}.yml"

  depends_on = [
    module.server
  ]
}

resource "local_file" "vector_config" {
  content = templatefile("template/vector_config.tmpl",
    {
     clickhouse_host_ip = module.clickhouse.nodes_ip
     lighthouse_host_ip = module.lighthouse.nodes_ip
     server_host_ip = module.server.nodes_ip
    }
  )
  filename = "../group_vars/${local.ansible_inventory[terraform.workspace]}/vector/vars.yml"

  depends_on = [
    local_file.ansible_inventory
  ]
}

resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 40"
  }

  depends_on = [
    local_file.vector_config
  ]
}

resource "null_resource" "ansible_galaxy" {
  provisioner "local-exec" {
    command = "cd .. && ansible-galaxy install -r requirements.yml -p roles"
  }

  depends_on = [
    null_resource.wait
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../inventory/${terraform.workspace}.yml ../site.yml"
  }

  depends_on = [
    null_resource.ansible_galaxy
  ]
}
