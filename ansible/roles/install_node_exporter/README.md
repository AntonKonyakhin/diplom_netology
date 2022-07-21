Role Name
=========

install_node_exporter - установка и настройка node exporter

Requirements
------------

YC  
Ubuntu 18.04


Role Variables
--------------

node_exporter_exec_command - строка выполнения node exporter  
node_exporter_groupId  - группа node_exporter  
node_exporter_userId  - пользователь node_exporter  
node_exporter_version - версия файла node_exporter  



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
