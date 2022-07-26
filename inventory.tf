resource "local_file" "inventory" {
  content = <<-DOC
    # Ansible inventory containing variable values from Terraform.
    # Generated by Terraform.
  ---
  nginx:
    hosts:
      nginx-1:
        ansible_host: ${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}
        ansible_user: ubuntu
  mysql:
    hosts:
      db-01:
        ansible_host: ${resource.yandex_compute_instance.db01.network_interface.0.ip_address}
        ansible_user: ubuntu
      db-02:
        ansible_host: ${resource.yandex_compute_instance.db02.network_interface.0.ip_address}
        ansible_user: ubuntu
    vars:
      ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o ProxyCommand='ssh -W %h:%p -q ubuntu@${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}'"
  wordpress:
    hosts:
      app:
        ansible_host: ${resource.yandex_compute_instance.app.network_interface.0.ip_address}
        ansible_user: ubuntu
    vars:
      ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o ProxyCommand='ssh -W %h:%p -q ubuntu@${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}'"

  monitoring:
    hosts:
      prometeus:
        ansible_host: ${resource.yandex_compute_instance.monitoring.network_interface.0.ip_address}
        ansible_user: ubuntu
    vars:
      ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o ProxyCommand='ssh -W %h:%p -q ubuntu@${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}'"  
  gitlabrunner:
    hosts:
      gitlab:
        ansible_host: ${resource.yandex_compute_instance.gitlab.network_interface.0.ip_address}
        ansible_user: ubuntu
      runner:
        ansible_host: ${resource.yandex_compute_instance.runner.network_interface.0.ip_address}
        ansible_user: ubuntu
    vars:
      ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o ProxyCommand='ssh -W %h:%p -q ubuntu@${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}'"
  
    DOC
  filename = "ansible/inventory/prod.yml"

  depends_on = [
    yandex_compute_instance.vm-1,yandex_compute_instance.runner,
  ]
}

 resource "local_file" "group_vars" {
  # получаем имена сайтов, путем отрезания последней точки с конца.connection 
  # иначе name_server в конфиге nginx получается с точкой и при вводе адреса в браузер попадаем на страницу по умолчанию  
  
   content = <<-DOC
    ---
    custom_var: all
    domain_main: ${trimsuffix(yandex_dns_zone.dns_zone1.zone, ".")}
    domain_www: ${trimsuffix(yandex_dns_recordset.www.name, ".")}
    domain_gitlab: ${trimsuffix(yandex_dns_recordset.gitlab.name, ".")}
    domain_grafana: ${trimsuffix(yandex_dns_recordset.grafana.name, ".")}
    domain_prometheus: ${trimsuffix(yandex_dns_recordset.prometheus.name, ".")}
    domain_alertmanager: ${trimsuffix(yandex_dns_recordset.alertmanager.name, ".")}
    letsencrypt_email: ${var.email}
    squid_port: 3128
    ip_nginx: ${resource.yandex_compute_instance.vm-1.network_interface.0.ip_address}
    proxy_env:
      http_proxy: http://${resource.yandex_compute_instance.vm-1.network_interface.0.ip_address}:3128
      https_proxy: http://${resource.yandex_compute_instance.vm-1.network_interface.0.ip_address}:3128
    ssh_args: "-o StrictHostKeyChecking=no -o ProxyCommand='ssh -W %h:%p -q ubuntu@${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}'"
    db_user: wordpress
    db_pass: wordpress
    db_name: wordpress
    mysql_pass: 'netology'
    repl_user: repl
    repl_pass: netology
    master_host: ${resource.yandex_compute_instance.db01.network_interface.0.ip_address}
    slave_host: ${resource.yandex_compute_instance.db02.network_interface.0.ip_address}
    ip_wordpress: ${resource.yandex_compute_instance.app.network_interface.0.ip_address}
    ip_monitoring: ${resource.yandex_compute_instance.monitoring.network_interface.0.ip_address}
    prometheus_version: 2.36.2
    alertmanager_version: 0.24.0
    node_exporter_serviceName: "node_exporter"
    node_exporter_userId: "node_exporter"
    node_exporter_groupId: "node_exporter"
    node_exporter_exec_command: /usr/local/bin/node_exporter
    node_exporter_version: 1.3.1
    grafana_admin_user: admin
    grafana_admin_password: grafana
    name_runnerultra: ${resource.yandex_compute_instance.vm-1.name}
    name_db01: ${resource.yandex_compute_instance.db01.name}
    name_db02: ${resource.yandex_compute_instance.db02.name}
    name_wp: ${resource.yandex_compute_instance.app.name}
    name_gitlab: ${resource.yandex_compute_instance.gitlab.name}
    name_runner: ${resource.yandex_compute_instance.runner.name}
    name_monitoring: ${resource.yandex_compute_instance.monitoring.name}
    gitlab_in: ${resource.yandex_compute_instance.gitlab.network_interface.0.ip_address}
    runner_in: ${resource.yandex_compute_instance.runner.network_interface.0.ip_address}
    gitlab_root_password: "mystrongpassword"
    reg_token_gitlab: "tck65cZ3aZ4_YZzLvwQ5"
    runner_name: "shell-runner"
 
   DOC

  filename = "ansible/group_vars/all.yml"
   depends_on = [
    yandex_compute_instance.vm-1,yandex_compute_instance.runner,
  ]

}

 resource "local_file" "files_proxy_config" {
  # proxy config file for apt
   content = <<-DOC
   Acquire::http::Proxy "http://${resource.yandex_compute_instance.vm-1.network_interface.0.ip_address}:${var.proxy_port}/";
   Acquire::http::Proxy "http://${resource.yandex_compute_instance.vm-1.network_interface.0.ip_address}:${var.proxy_port}/";
    
    
   DOC

  filename = "ansible/files/proxy.conf"
   depends_on = [
    yandex_compute_instance.vm-1,
  ]
 }

resource "local_file" "script_post" {
  # proxy config file for apt
   content = <<-DOC
   wp post create ./post-content.txt --post_type=post --post_status=Publish --post_title='A sample post' --path=/var/www/wordpress2/html/wordpress    
   
   DOC

  filename = "script/post.sh"
   depends_on = [
    yandex_compute_instance.vm-1,
  ]
 }

 resource "local_file" "post_content" {
  # proxy config file for apt
   content = <<-DOC
    Post post post!!!

    Hello, NETOLOGY
    
    Post post post!!!


   DOC

  filename = "script/post-content.txt"
   depends_on = [
    yandex_compute_instance.vm-1,
  ]
 }

resource "local_file" "gitlab_ci" {
  # proxy config file for apt
   content = <<-DOC
---
stages:
  - build
  - test
  - deploy

build-job:
  stage: build
  script:
    - echo "Compiling the code..."
    - echo "Compile complete."

unit-test-job:
  stage: test
  script:
    - echo "Running unit tests... This will take about 60 seconds."
    - sleep 60
    - echo "Code coverage is 90%"

lint-test-job:
  stage: test
  script:
    - echo "Linting code... This will take about 10 seconds."
    - sleep 10
    - echo "No lint issues found."

deploy-job:
  rules:
    - if: '$CI_COMMIT_TAG != null'
  stage: deploy
  script:
    - echo "Deploying application..."
    - scp post.sh ubuntu@${resource.yandex_compute_instance.app.network_interface.0.ip_address}:post.sh
    - scp post-content.txt ubuntu@${resource.yandex_compute_instance.app.network_interface.0.ip_address}:post-content.txt
    - ssh ubuntu@${resource.yandex_compute_instance.app.network_interface.0.ip_address}
         "chmod 755 post.sh && /bin/bash /home/ubuntu/post.sh"
    - echo "Application successfully deployed."

   DOC

  filename = "script/.gitlab-ci.yml"
   depends_on = [
    yandex_compute_instance.vm-1, yandex_compute_instance.app,
  ]
 }

resource "local_file" "gitlab_push" {
  # proxy config file for apt
   content = <<-DOC
   git init
   git config --global http.sslverify false
   git remote add origin https://root:mystrongpassword@gitlab.runnerultra.ru/root/333.git
   git add .
   git commit -m "my first post"
   git push origin --set-upstream master
   git tag "v0.0.1"
   git push --tags origin

   DOC

  filename = "script/gitlab_push.sh"
   depends_on = [
    yandex_compute_instance.vm-1, yandex_compute_instance.app,
  ]
 }