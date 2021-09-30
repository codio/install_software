#!/bin/bash

bash -c "$(curl -fsSL https://raw.github.com/codio/install_software/13175_x_server/tools/ansible.sh)" xserver

echo
echo "******************************************************************************************************"
echo "*    YOU MUST NOW RESTART YOUR BOX FROM THE MENU Project-Restart Box.                                *" 
echo "******************************************************************************************************"
echo
echo "A Virtual Desktop item has been added automatically to the Preview menu in the menu bar above to allow you access X-server."
echo "For more information on this see https://docs.codio.com/common/develop/ide/boxes/installsw/gui.html"
