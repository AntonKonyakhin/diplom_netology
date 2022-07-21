Role Name
=========

install_prometheus

Requirements
------------

YC  
Ubuntu 18.04


Role Variables
--------------

ip_nginx - внутренний ip reverse proxy  
name_runnerultra - имя сервера с внешним ip и reverse-proxy  
master_host - ip сервер с mysql с master  
name_db01 - имя сервера с mysql с master  
slave_host - ip сервер с mysql с slave  
name_db02  - имя сервера с mysql с slave  
ip_wordpress  - ip сервера с wordpress  
name_wp  -  имя сервера с wordpress  
gitlab_in  - ip сервера с gitlab  
name_gitlab  - имя сервера с gitlab  
runner_in  - ip сервера с gitlab-runner  
name_runner  - имя сервера с gitlab-runner  
prometheus_version  -  версия prometheus для установки  


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
