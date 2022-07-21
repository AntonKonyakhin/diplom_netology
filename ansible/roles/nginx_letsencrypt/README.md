Role Name
=========

nginx_letsencrypt

Requirements
------------

YC  
Ubuntu 18.04

Role Variables
--------------

domain_alertmanager  - адрес сайта с alertmanager  
letsencrypt_email  - email для получения сертификата  
domain_www  - адрес основного сайта с wordpress  
domain_prometheus  - адрес сайта с prometheus  
domain_gitlab  - адрес сайта с gitlab  
domain_main  - адрес основного сайта с wordpress без www  
domain_grafana - адрес сайта с grafana  
domain_gitlab  - адрес сайта с gitlab  
ip_monitoring - ip адрес сервера мониторинга(с alertmanager, grafana, prometheus)  
gitlab_in - ip адрес сервера с gitlab  


Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

Anton Konyakhin
