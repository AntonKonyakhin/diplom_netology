Role Name
=========

install_gitlab

Requirements
------------

YC
Ubuntu 18.0.4

Role Variables
--------------

gitlab_root_password  - пароль для админитратора gitlab
reg_token_gitlab  - токен доступа к gitlab через cli
domain_gitlab  - имя домена, где расположен сайт gitlab
gitlab_in  - внутренний ip машины с gitlab




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
