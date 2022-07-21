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
4)  здесь должна быть роль конфигурирования mysql master-slave, но она сейчас описана в виде tasks в основном yml-файле - site.yml;  
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

### как пользоваться:  
1) нобходимо склонировать проект из репозитория git и роли
https://github.com/AntonKonyakhin/diplom_netology


2) установить terraform, ansible
3) создать backet в YC
4) заполнить переменные своими значениями:

```
export YC_CLOUD_ID=""
export YC_FOLDER_ID=""
export YC_SERVICE_ACCOUNT_KEY_FILE="key.json"
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```


YC_CLOUD_ID и YC_FOLDER_ID значения можно посмотреть:
https://console.cloud.yandex.ru/cloud?section=overview


свой token можно посмотреть здесь, но лучше создать сервисный аккаунт
https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb


AWS_SECRET_ACCESS_KEY и AWS_ACCESS_KEY_ID
создать ключи для сервисного аккаунта можно так(из документации yc):
```
yc iam access-key create --service-account-name my-robot

```

YC_SERVICE_ACCOUNT_KEY_FILE

```
yc iam key create --service-account-name default-sa --output key.json

```

так же в файле var.tf подставить свои значения


6) запустить команду:

```
terraform apply --auto-approve
```

7) чтобы проверить работу CI\CD:
  - необходимо открыть сайт https://www.runnerultra.ru  
  в данный момент на нем нет постов за исключением стандартного Hello, World
  - необходимо зайти в папку script
  - запустить скрипт gitlab_push.sh
  - дождаться, когда выполниться ci\cd скрипт по тегу
  - снова открыть сайт или обновить страницу и после этого увидим новый пост

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