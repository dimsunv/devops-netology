resource "local_file" "inventory" {
  content = <<-DOC
  ---
  clickhouse:
    hosts:
      clickhouse-1:
        ansible_user: ${module.clickhouse.user_name}
        ansible_host: ${module.clickhouse.instance_ip}
  vector:
    hosts:
      vector-1:
        ansible_user: ${module.vector.user_name}
        ansible_host: ${module.vector.instance_ip}
  DOC
  filename = "../inventory/prod.yml"

  depends_on = [
    module.clickhouse
  ]
}

resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 60"
  }

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "chmod" {
  provisioner "local-exec" {
    command = "chmod -R 755 /home/boliwar/08-ansible-02-playbook"
  }

  depends_on = [
    null_resource.wait
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../inventory/prod.yml ../site.yml"
  }

  depends_on = [
    null_resource.chmod
  ]
}
