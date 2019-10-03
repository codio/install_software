#!/bin/bash

bash -c "$(curl -fsSL https://raw.github.com/codio/install_software/master/tools/ansible.sh)" ungit

echo
echo "Add the line to you preview configuration to access ungit from the Menu"
echo '   "ungit": "https://{{domain8000}}/"'