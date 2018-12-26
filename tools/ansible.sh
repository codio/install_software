#!/bin/bash

COOKBOOK_PATH=/tmp/codio_playbook
BRANCH=9995_updates

IS_TRUSTY () { lsb_release -a | grep trusty }
IS_XENIAL () { lsb_release -a | grep xenial }
IS_BIONIC () { lsb_release -a | grep bionic }

do_cmd()
{
	echo "Running [ $@ ]"
    "$@"
    ret=$?
    if [[ $ret -eq 0 ]]
    then
        echo "Successfully ran [ $@ ]"
    else
        echo "Error: Command [ $@ ] returned $ret"
        echo "One more attempt for [ $@ ] after delay"

        sleep 5

        "$@"
	    ret=$?
	    if [[ $ret -eq 0 ]]
	    then
	        echo "Successfully ran [ $@ ]"
	    else
	    	echo "Error: Command [ $@ ] returned $ret - Exiting"
        	exit $ret
        fi
    fi
}

download_playbook()
{
   rm -rf ${COOKBOOK_PATH}
   mkdir ${COOKBOOK_PATH}
   curl -fsSL https://github.com/codio/install_software/archive/${BRANCH}.tar.gz  | tar zxf - -C ${COOKBOOK_PATH}
}

if IS_TRUSTY; then
    ansible --version | grep '2.2.0.0' 2> /dev/null
fi
if IS_XENIAL; then
    ansible --version | grep '2.7.5.0' 2> /dev/null
fi
if IS_BIONIC; then
    ansible --version | grep '2.7.5.0' 2> /dev/null
fi
is_ansible_right=$?
if [ $is_ansible_right -ne 0 ]; then
    do_cmd sudo apt-get update
	do_cmd sudo apt-get -y install wget python python-support python-yaml python-httplib2 python-setuptools python-markupsafe python-jinja2 python-paramiko sshpass
    if IS_TRUSTY; then
        do_cmd sudo wget -O /tmp/ansible.deb https://raw.githubusercontent.com/codio/install_software/${BRANCH}/tools/ansible_2.2.0.0-1ppa~trusty_all.deb
    fi
    if IS_XENIAL; then
        do_cmd sudo wget -O /tmp/ansible.deb https://raw.githubusercontent.com/codio/install_software/${BRANCH}/tools/ansible_2.7.5.0-1ppa~trusty_all.deb
    fi
    if IS_BIONIC; then
        do_cmd sudo wget -O /tmp/ansible.deb https://raw.githubusercontent.com/codio/install_software/${BRANCH}/tools/ansible_2.7.5.0-1ppa~trusty_all.deb
    fi
	do_cmd sudo dpkg -i /tmp/ansible.deb
    do_cmd sudo rm /tmp/ansible.deb
fi

download_playbook

sudo ansible-playbook -v ${COOKBOOK_PATH}/install_software-${BRANCH}/$0/playbook.yaml

