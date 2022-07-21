Role Name
=========

wordpress

Requirements
------------

YC  
Ubuntu 18.04

Role Variables
--------------

ip_nginx  - ip адрес сервера с reverse-proxy  
squid_port  - порт squid  
db_name  - имя базы данных, которой подключается wordpress  
db_user  - имя пользователя с правами на бзу данных  
db_pass  - пароль пользователя  
master_host  - ip адрес сервера с mysql master


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