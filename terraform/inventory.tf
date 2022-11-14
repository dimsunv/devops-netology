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

resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 40"
  }

  depends_on = [
    local_file.ansible_inventory
  ]
}

resource "null_resource" "chmod" {
  provisioner "local-exec" {
    command = "chmod -R 755 /home/boliwar/08-ansible-03-yc"
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
    null_resource.chmod
  ]
}
