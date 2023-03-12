resource "local_file" "kubespray_config" {
  content = templatefile("template/inventory.tmpl",
    {
    
     node_host_name = module.node.name
     node_host_ip = module.node.nodes_public_ip

    }
  )
  filename = "${var.kubespray_cluster_path}/hosts.yaml"
  
  provisioner "local-exec" {
    command = <<-EOT
      sed -i -e 's/.*container_manager:.*/container_manager: docker/' ${var.kubespray_config_path}/k8s-cluster.yml
      sed -i -e 's/.*supplementary_addresses_in_ssl_keys:.*/supplementary_addresses_in_ssl_keys: [${module.node.nodes_public_ip[0]}]/' ${var.kubespray_config_path}/k8s-cluster.yml
      sed -i -e 's/.*dashboard_enabled:.*/dashboard_enabled: false/' ${var.kubespray_config_path}/addons.yml
      sed -i -e 's/.*metrics_server_enabled:.*/metrics_server_enabled: false/' ${var.kubespray_config_path}/addons.yml
      sed -i -e 's/.*ingress_nginx_enabled:.*/ingress_nginx_enabled: true/' ${var.kubespray_config_path}/addons.yml
      sed -i -e 's/.*ingress_nginx_host_network:.*/ingress_nginx_host_network: true/' ${var.kubespray_config_path}/addons.yml
    EOT
  }
  depends_on = [
    module.node
  ]
}

resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 40"
  }

  depends_on = [
    local_file.kubespray_config
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ~/kubespray/inventory/mycluster/hosts.yaml  --become ~/kubespray/cluster.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}
