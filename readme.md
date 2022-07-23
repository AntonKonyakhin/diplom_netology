## Дипломное задание по курсу «DevOps-инженер»
Задание:
- Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
- Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
- Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
- Настроить кластер MySQL.
- Установить WordPress.
- Развернуть Gitlab CE и Gitlab Runner.
- Настроить CI/CD для автоматического развёртывания приложения.
- Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

Описание:
- данный проект использует `terraform`, `ansible`, `yandex cloud`  
- поднимает машины со следующими характеристиками:


 vm name | cpu | ram | назначение|
---|--|--|--|
runnerultra.ru |2|2| reverse-proxy|
db01.runnerultra.ru  | 4  |4| mysql / master| 
db02.runnerultra.ru  | 4  |4| mysql / slave|
app.runnerultra.ru  | 4  |4| wordpress|
gitlab.runnerultra.ru  | 4  |4| gitlab|
runner.runnerultra.ru  | 4  |4| gitlab-runner / shell executor|
monitoring.runnerultra.ru  | 4  |4| Prometheus, Alert Manager и Grafana|

### описание машин для создания через terraform в файлах:  
main.tf  - runnerultra.ru  
db.tf  - db01.runnerultra.ru, db02.runnerultra.ru  
gitlabrunner.tf  - gitlab.runnerultra.ru, runner.runnerultra.ru  
monitoring.tf  - monitoring.runnerultra.ru  
wordpress.tf  - app.runnerultra.ru  

### переменные для ansible формируются автоматически в файле:  
inventory.tf
Этот  файл так же формирует автоматически скрипт для создания поста через ci\cd по наличию тега  

### запуск ansible через terraform происходит из файла:  
ansible.tf

### переменные для terraform формируются в файле 
vars.tf  


### образы для vm:  
иcпользуется образ ubuntu 18.04 из Yandex Cloud

### домен:  
Зарегистрированное доменное имя: `runnerultra.ru`  

### доступность сервисов:  
https://www.runnerultra.ru (WordPress)  
https://gitlab.runnerultra.ru (Gitlab)  
https://grafana.runnerultra.ru (Grafana)  
https://prometheus.runnerultra.ru (Prometheus)  
https://alertmanager.runnerultra.ru (Alert Manager)  


### 1. Регистрация доменного имени  
Зарегистрировал домен `runnerultra.ru` на сайте nic.ru. В настройках прописал делегирование DNS на YC.

![domain](/screenshot/domen.jpg)

### 2. Создание инфраструктуры
установил из зеркала последний terraform на машину(ОС ubuntu). с помощю wget скачал и скопировал в /usr/bin 
https://hashicorp-releases.yandexcloud.net/terraform/1.1.9/

дальше установил yс для работы с облаком yandex cloud.
```
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```
далее настроил yc 
```
 yc init
```
Создал сервисный аккаунт в YC. по инструкции  
Назначил сервисному аккаунту роль `editor`

```
root@ubuntu-ansible:~/yc_terraform# yc resource-manager folder add-access-binding new-netology --role editor --subject serviceAccount:ajedoqo47sqalfrcf3ki
done (1s)

```

![service-account](/screenshot/service-account.jpg)

Создал workspace для terraform с именем stage
```
terraform workspace new stage
```

создал secret key для сервисного аккаунта
```
yc iam access-key create 

```
прописал переменные:

```
export YC_CLOUD_ID=""
export YC_FOLDER_ID=""
export YC_SERVICE_ACCOUNT_KEY_FILE="key.json"
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```


создал бакет в Яндекс облаке с помощью terraform  
чтобы можно было сделать terraform init, прописал в файл зеркало на регистр terraform  
```
cat ~/.terraformrc 
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

![бакет](/screenshot/bucket.jpg)

Далее создал 2 подсети в зонах  
ru-central1-a  
ru-central1-b  

в файле vars.tf они определены как переменные  
yc_zone  
yc_zone_2  

в файле main.tf описано создание сети:  
resource "yandex_vpc_network" "network-1"  

### 3. Установка Nginx и LetsEncrypt

В файле main.tf описал настройки для создания машины runnerultra.ru с nginx. 
в тестовых целях прописал настройки прерываемости машины и произвоительности cpu  
interruptable  
default = true  

fract_cpu  
default = 20  

в проекте в папке /ansible расположен файл site.yml и роли в папке roles.

создал роль squid и nginx_letsencrypt  
роль squid: 

   - требуется для того, чтобы машины из внутренней сети смогли попасть в интернет для установки софта. 

   - первая task выполняет установку squid.  

   - далее прописываем в файле конфигурации строку /http_access deny all/http_access allow all/' /etc/squid/squid.conf  

   - далее делвем enable сервису и перезапускаем squid  


роль nginx_letsencrypt:  
   - требуется для установки nginx в качестве reverse-proxy и получения ssl сертификатов от letsencrypt  
   заранее подготовил файлы с конифигами для сайтов в папке templates. С перенаправление на сайты  
     https://www.runnerultra.ru (WordPress)    
     https://gitlab.runnerultra.ru (Gitlab)   
     https://grafana.runnerultra.ru (Grafana)   
     https://prometheus.runnerultra.ru (Prometheus)   
     https://alertmanager.runnerultra.ru (Alert Manager) 

   - устанавливаем утилиты letsencrypt и nginx  
   создаем папку /var/www/letsencrypt 

   - скопировал файлы с конфигами в папку /etc/nginx/sites-available  
   - сделал на них link  

   - далее получил сертификаты с помощью команды 
   ```
   letsencrypt certonly -n --webroot -w /var/www/letsencrypt \
           -m {{ letsencrypt_email }} --agree-tos \
           -d {{ domain_www }} \
           -d {{ domain_prometheus }} \
           -d {{ domain_alertmanager }} \
           -d {{ domain_gitlab }} \
           -d {{ domain_grafana }}"
```
    далее перезапустил nginx

в файле main.tf прописал создание A-записей в Yandex Cloud  


### 4. Установка кластера MySQL  
описание машин в файле db.tf  
подключение к таким машинам, которые только во внутренней сети, происходит через jump хост, вот в таком виде:  
```
vars:
      ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o ProxyCommand='ssh -W %h:%p -q ubuntu@${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}'"
```


сначала выполняется претаска для копирования конфига для apt, чтобы он мог пройти в интернет через rteverse-proxy.
копирование файла proxy.conf в паку /etc/apt/apt.conf.d/proxy.conf  

и в переменные окружения прописыва.тся настройки прокси:  
```
  environment:
    http_proxy: http://{{ ip_nginx }}:3128
    https_proxy: http://{{ ip_nginx }}:3128
```

далее  выполняется роль mysql-install  
- она просто устанавливает mysql на два узла  

далее запускается роль master_slave  
  - добавляем настройки в файл mysqld.cnf, такие как:  
  'bind-address = 0.0.0.0'  
  'server-id = 1'  
  'log_bin = /var/log/mysql/mysql-bin.log'  
  'binlog_do_db = {{ db_name }}'  

  - перезапускаем mysql  
  далее с помощью модулей ansible для mysql создаем базу и пользоателя базы, а также пользователя для репликации  
  
  - Далее в этой роли идет настройка узла slave
  проверяем является ли узел настроенным как slave с помощью ansible модуля mysql_replication, если нет, то продолжаем настройку.  
  - создаем базу с тем же именем, что и на мастере  
  - далее прописываем настройки в файл /etc/mysql/mysql.conf.d/mysqld.cnf  
  'server-id = 2'  
  'log_bin = /var/log/mysql/mysql-bin.log'  
  'log_bin = /var/log/mysql/mysql-relay-bin.log'  
  'binlog_do_db = {{ db_name }}'  
  - рестартуем сервис mysql  
  - далее производим настройку с помощью модуля mysql_replication  
  ```
  mysql_replication:
        mode: changemaster
        master_user: '{{ repl_user }}'
        master_password: '{{ repl_pass }}'
        master_host: '{{ master_host }}'
        master_log_file: "{{ hostvars['db-01']['mysql_result']['File'] }}"
        master_log_pos: "{{ hostvars['db-01']['mysql_result']['Position'] }}"
  ```
  - запускаепм репликацию:
  ```
  mysql_replication:
        mode: startslave
  ```

### 5. Установка WordPress  

для создания машины использовал описание в файле wordpress.tf  
для настройки создал роли  
  roles:  
    - php  
    - nginx-wordpress  
    - wordpress  
    - wordpress_config  
- роль php  
  с помощью этой роли устанавливаем необходимые компоненты для wordpress:  
    - php-cli
    - php-fpm
    - php-mysql
    - php-json
    - php-curl
    - php-gd
    - php-intl
    - php-mbstring
    - php-soap
    - php-xml
    - php-xmlrpc
    - php-zip  
 - далее перезапускаем php-fpm  

- роль nginx-wordpress  
  - устанавливает nginx и копирует файл конфигурации из папки в папку  
  - настраивает nginx на порт 80 и и папку с wordpress /var/www/wordpress2/html/wordpress  
  и открыввает сраницу, если к нему обратились по ip адресу  server_name {{ ip_wordpress }};

- роль wordpress  
  - этой ролью создаю папку /var/www/wordpress2/html  
  далее с помощью модуля ansible.builtin.unarchive  скачиваем и распаковываем wordpress
  - выдаем права для пользователя www-data  
  - далее проверяю наличие файла /var/www/wordpress2/html/wordpress/wp-config.php, если его нет, то копирую файл из wp-config.j2  
  - в этом файле wp-config.php настройки подключения к базе, там же прописана настройка, чтобы сайт работал по https:  
  $_SERVER['HTTPS']='on';  
  - важно эту настройку прописать до этой строчки:  
  /* That's all, stop editing! Happy publishing. */  
  так как, если ее прочитать, то становится понятно, что если добавить настройку в конец файла, то настройка не применится  
  


- роль wordpress_config  
  - эту роль для конфигурации wordpress через wp-cli  
  скачивается утилита wp в папку /usr/local/bin/wp"  
  далее проверяю установлен ли wordpress в папку /var/www/wordpress2/html/wordpress:  
  wp core is-installed  
  - если не установлен, то запускаю команду утановки wordpress:  
  ```
  - name: Install WordPress tables 
    command: wp core install
            --url="https://www.runnerultra.ru"
            --title="runnerultra"
            --admin_user="admin"
            --admin_password="admin"
            --admin_email="admin_wp@example.com"

  ```
### 6. Установка Prometheus, Alert Manager, Node Exporter и Grafana  
машина описана в файле monitoring.tf  
Сделал ansible-роль install_node_exporter, которую прогнал на всех узлах отдельной таской  
роль install_node_exporter  
  - скачиваем и копируем node-exporter сюда /usr/local/bin/node_exporter  с правами для созданного пользователя  
  - подготовил Unit файл для запуска node_exporter как сервис, в файле templates/init.service.j2. 
  - стартуем сервис  

роль install_prometheus для машины monitoring  
  - создаю пользователя prometheus и групппу prometheus для - запуска сервиса  
  - создал Unit файл для запуска prometheus как скрвис, файл prometheus.service  
  - создал файл с настройками мониторинга prometheus.yuml.j2, куда записал узлы и где прописаны правила:  
  - правила в файле:  
  ```yml
  rule_files:
    - alert_rules.yml
  ```
  - узлы
  ```yml
  scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: '{{ name_monitoring }}'

    static_configs:
      - targets: ['localhost:9100']
  - job_name: 'nodes'
    static_configs:
      - targets: ['{{ ip_nginx }}:9100']
        labels: {'host': '{{ name_runnerultra }}' }
      - targets: ['{{ master_host }}:9100']
        labels: {'host': '{{ name_db01 }}' }
      - targets: ['{{ slave_host }}:9100']
        labels: {'host': '{{ name_db02 }}' }
      - targets: ['{{ ip_wordpress }}:9100']
        labels: {'host': '{{ name_wp }}' }
      - targets: ['{{ gitlab_in }}:9100']
        labels: {'host': '{{ name_gitlab }}' }
      - targets: ['{{ runner_in }}:9100']
        labels: {'host': '{{ name_runner }}' }

  ```
  - скачиваю prometheus и копирую утилиты в соответствующие папки  
  prometheus, promtool в папку /usr/local/bin/  
  console_libraries, consoles, prometheus.yml в папку /etc/prometheus/  
  - копирую кастомные prometheus.yml и Unit файл  
  стартую сервис prometheus  

роль install_alertmanager  
  - заранее подготовил файлы alertmanager.service и файл с правилами alert.rules  
  - этой ролью создаю пользователя и группу для запуска сервиса  
  - скачиваю с сайта утилиту alertmanager  
  - копирую файлы alertmanager.service и файл с правилами alert.rules  
  - стартую сервис alertmanager  

роль install_grafana  
  - заранее подготовил файл для подключения дашборда по пути path: /var/lib/grafana/node-exporter.json  и к prometheus  
  - устанавливаем необходимый компонент apt-transport-https  
  копируем gpg ключ с помощью модуля ansible.builtin.apt_key  
  - добавляем рупозиторий grafana с помощью модуля  ansible.builtin.apt_repository  
  - производим установку grafana  
  - копирую настройки подключения к prometheus из файла templates/prometheus.j2 в /etc/grafana/provisioning/datasources/prometheus.yml  
  - запускаем сервис  
  - жду поднятия сайта с помощью модуля ansible.builtin.uri, жду код 200  
  - далее устанавыливая пароль админа  
  - скачиваю дашбоар https://raw.githubusercontent.com/rfrail3/grafana-dashboards/master/prometheus/node-exporter-full.json  
  - копирую конфиг подключения дашбоарда из файла dashboard-node-exporter.yml.j2  
  - перезапуск grafana  

### 7. Установка Gitlab CE и Gitlab Runner  

машины с gitlab и gitlab-runner описаны в файле  gitlabrunner.tf  
в претаске я прописываю адрес gitlab в hosts на машине gitla-runner, чтобы он из внутренней сети смог до нее добраться    
```
      ansible.builtin.lineinfile:
        path: /etc/hosts
        line: "{{ ip_nginx }} {{ domain_gitlab }}"
      when:
        - inventory_hostname == 'runner'

```
роль  install_gitlab  
- устаналивает для gitlab пакеты  
    - curl  
    - openssh-server  
    - ca-certificates  
    - tzdata  
    - perl  
    - wget  
- проверяю существование папки check_gitlab, если ее нет, то скачиваю скрипт с сайта gitlab  
- далее запускаю его  
- после этого устанавливаю gitlab-ce  
- задаю пароль в файле:  
```yml
path: /etc/gitlab/gitlab.rb
    regexp: "# gitlab_rails\\['initial_root_password'\\]"
    line: gitlab_rails['initial_root_password'] = "{{ gitlab_root_password }}"

```
- для доступа к gitlab из командной строки задаю token: 
```yml
   path: /etc/gitlab/gitlab.rb
    regexp: "# gitlab_rails\\['initial_shared_runners_registration_token'\\]"
    line: gitlab_rails['initial_shared_runners_registration_token'] = "{{ reg_token_gitlab }}"
```
- в этом же файле /etc/gitlab/gitlab.rb прописываю адрес сайта external_url 'https://{{ domain_gitlab }}'  
далее внес изменния, чтобы он за реверс прокси работал на 80 порту:  
line: "nginx['listen_port'] = 80"  
line: "nginx['listen_https'] = false"  

- после внесения изменений запускаю реконфигур  
```
gitlab-ctl reconfigure
```

- далее в этой роли произвожу установку gitlab-runner  
- по аналогии с gitlab, скачиваю скрипт с сайта, запускаю скрипт, а затем устанапвливаю gitlab-runner из репозитория с помощью модуля ansible.builtin.apt  
- далее, чтобы при нескльких прогоназх роли не регистрировать не сколько раз runner, проверяю зарегистрирован ли раннер и результат записываю в переменную  
- если раннер не зарегистрирован, то регистрирую командой:  
```
  command: "gitlab-runner register --non-interactive \
            --name 'shell-runner' \
            --url http://{{ gitlab_in }} --registration-token {{ reg_token_gitlab }} \
            --executor shell \
            --tag-list 'dev_shell' \
            --run-untagged='true'"
``` 
- чтобы раннер мог подключаться к wordpress по ssh и что-то там выполнять, создаю ключи ssh для пользователя gitlab-runner и копирую их на машину с wordpress к пользователю ubuntu  
```
openssh_keypair:
    path: /home/gitlab-runner/.ssh/id_rsa
    owner: gitlab-runner
    group: gitlab-runner
    state: present
```

- считываю публичный ключ в переменную source_rsa_key_encoded  
- чтобы считать переменную из таски, которая выполнялась для другой группы хостов использую  hostvars
hostvars['runner']['source_rsa_key_encoded']['content'] | b64decode  

- добавляю ключ пользователю ubuntu и выставляю правильные права  
```
    path: "/home/ubuntu/.ssh/authorized_keys"
    line: "{{ source_rsa_key }}"
    state: present
    mode: '0600'
  when:
    - inventory_hostname == 'app'
```
- чтобы при первом подключении не возникало сообщения о подтверждении, прописал на раннере настройку  
```
  ansible.builtin.lineinfile:
    path: "/etc/ssh/ssh_config"
    line: "Host * \n \
             StrictHostKeyChecking no \n \
             UserKnownHostsFile=/dev/null"
    state: present
  when:
    - inventory_hostname == 'runner'
```

### фалй inventory.tf  
в этом файле создаю:  
  prod.yml с хостами  
  содаю файл ansible/group_vars/all.yml в котором размещены переменные для ansible ролей  
  создаю ansible/files/proxy.conf конфигурация для apt для машин во внуртренней сети  
  script/post.sh - для ткстирования CI/CD  
  script/post-content.txt - содердит пост для тестирования CI/CD  
  script/.gitlab-ci.yml - CI/CD скрипт  

 


### Ansible-роли:
1)  `nginx_letsencrypt`:
     - выполняет установку nginx на машину runnerultra.ru;
     - выполняет получение ssl сертификатов LetsEncrypt;
     - конфигурирует nginx для доступности сервисов по https
2)  `squid`:
     - установа и конфигурирование squid на машину runnerultra.ru;
     - предназначен для установки софта на машины во внутренней части сети;
3)  `mysql-install`:
    - установка mysql на машины db01.runnerultra.ru и db02.runnerultra.ru;  
4)  `master_slave` - настраивает 2 узла с mysql как master slave;  
5) `php` :
    - установка необходимых компонентов php на машину app.runnerultra.ru для работы wordpress;  
6) `nginx-wordpress`:
    - установка и конфигурация nginx на машине app.runnerultra.ru;  
7) `wordpress`:
    - установка wordpress на машину app.runnerultra.ru(в папку /var/www/wordpress2/html);  
    - настройка через файл wp-config(подключаем к базе данных Mysql);  
8) `wordpress_config`:
    - скачиваем wp-cli и настраиваем сайт с помощью утилиты wp;  
9) `install_node_exporter`:
   - установка node exporter на все машины;  
10) `install_prometheus`:
   - установка prometheus и конфигурация на машине monitoring.runnerultra.ru;  
11) `install_alertmanager`:
   - установка alertmanager и конфигурация на машину monitoring.runnerultra.ru;  
12) `install_grafana`:
   - установка и конфигурация grafana на машину monitoring.runnerultra.ru;  
13) `install_gitlab`:
   - установка gitlab на машину  gitlab.runnerultra.ru;  
   - установка и регистрация gitlab-runner на машине runner.runnerultra.ru;


### чтобы проверить работу CI\CD:
  - необходимо открыть сайт https://www.runnerultra.ru  
  в данный момент на нем нет постов за исключением стандартного Hello, World
  - необходимо зайти в папку script
  - запустить скрипт gitlab_push.sh
  - дождаться, когда выполниться ci\cd скрипт по тегу
  - снова открыть сайт или обновить страницу и после этого увидим новый пост
  - чтобы изменить пост, можно добавить надпись в файл script/post-content.txt и еще раз выполнить push в гит

### пользователи и пароли:  
grafana:  
admin:grafana


gitlab:
root:mystrongpassword

### скриншоты:  
https://www.runnerultra.ru (WordPress)  


![WordPress](/screenshot/wordpress.jpg)

https://gitlab.runnerultra.ru (Gitlab)  

![Gitlab](/screenshot/gitlab.jpg)

https://grafana.runnerultra.ru (Grafana)  

![Grafana](/screenshot/grafana.jpg)

https://prometheus.runnerultra.ru (Prometheus)  

![Prometheus](/screenshot/prometheus.jpg)


https://alertmanager.runnerultra.ru (Alert Manager) 

![Alert Manager](/screenshot/alertmanager.jpg)


картинку с зарегистрированным раннером

![runner](/screenshot/runner.jpg)

картинка с pipline

![runner](/screenshot/pipeline.jpg)

картинка с постом

![post](/screenshot/post_ci_cd.jpg)