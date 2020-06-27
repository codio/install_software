#!/bin/bash

bash -c "$(curl -fsSL https://raw.github.com/codio/install_software/master/tools/ansible.sh)" mariadb

echo "Mysql password root user password is 'codio'"