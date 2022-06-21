#!/bin/bash

COOKBOOK_PATH=/tmp/codio_playbook

if test -n "${BRANCH}"
    BRANCH=jammy_support
end


CODENAME=$(lsb_release -c -s)
PY_FLAG=$1

IS_TRUSTY() { [ "${CODENAME}" == "trusty" ]; }
IS_XENIAL() { [ "${CODENAME}" == "xenial" ]; }
IS_BIONIC() { [ "${CODENAME}" == "bionic" ]; }
IS_JAMMY() { [ "${CODENAME}" == "jammy" ]; }
USE_PYTHON3() { [ "${PY_FLAG}" == "python3" ]; }

do_cmd()
{
    echo "Running [ $* ]"
    "$@"
    ret=$?
    if [[ $ret -eq 0 ]]
    then
        echo "Successfully ran [ $* ]"
    else
        echo "Error: Command [ $* ] returned $ret"
        echo "One more attempt for [ $* ] after delay"

        sleep 5

        "$@"
        ret=$?
        if [[ $ret -eq 0 ]]
        then
            echo "Successfully ran [ $* ]"
        else
            echo "Error: Command [ $* ] returned $ret - Exiting"
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
    ansible --version | grep -q '2.2.0.0' 2> /dev/null
    is_ansible_right=$?
fi
if IS_XENIAL; then
    ansible --version | grep -q '2.7.5' 2> /dev/null
    is_ansible_right=$?
fi
if IS_BIONIC; then
    ansible --version | grep -q '2.7.5' 2> /dev/null
    is_ansible_right=$?
fi
if IS_JAMMY; then
    ansible --version | grep -q '2.10' 2> /dev/null
    is_ansible_right=$?
fi

if [ $is_ansible_right -ne 0 ]; then
    do_cmd sudo apt-get update
    if USE_PYTHON3; then
      do_cmd sudo apt-get -y install python3 python3-apt
    fi
    if IS_TRUSTY; then
        do_cmd sudo apt-get -y install wget python python-support python-yaml python-httplib2 python-setuptools python-markupsafe python-jinja2 python-paramiko sshpass
        do_cmd sudo wget -O /tmp/ansible.deb https://raw.githubusercontent.com/codio/install_software/${BRANCH}/tools/ansible_2.2.0.0-1ppa~trusty_all.deb
    fi
    if IS_XENIAL; then
        do_cmd sudo apt-get -y install wget python python-cryptography python-crypto python-yaml python-httplib2 python-setuptools python-markupsafe python-jinja2 python-paramiko sshpass
        do_cmd sudo wget -O /tmp/ansible.deb https://raw.githubusercontent.com/codio/install_software/${BRANCH}/tools/ansible_2.7.5-1ppa_xenial_all.deb
    fi
    if IS_BIONIC; then
        do_cmd sudo apt-get -y install wget python python-crypto python-yaml python-httplib2 python-setuptools python-markupsafe python-jinja2 python-paramiko sshpass
        do_cmd sudo wget -O /tmp/ansible.deb https://raw.githubusercontent.com/codio/install_software/${BRANCH}/tools/ansible_2.7.5-1ppa_bionic_all.deb
    fi
    if IS_JAMMY; then
        do_cmd sudo apt update
        do_cmd sudo apt install -y ansible
    else
        do_cmd sudo dpkg -i /tmp/ansible.deb
        do_cmd sudo rm /tmp/ansible.deb
    fi
fi

download_playbook

do_cmd sudo apt-get update

if USE_PYTHON3; then
  sudo ansible-playbook -v "${COOKBOOK_PATH}/install_software-${BRANCH}/$0/playbook.yaml" -e 'ansible_python_interpreter=/usr/bin/python3'
elif IS_TRUSTY; then
    sudo ansible-playbook -v "${COOKBOOK_PATH}/install_software-${BRANCH}/$0/playbook.yaml"
else
    sudo ansible-playbook -v "${COOKBOOK_PATH}/install_software-${BRANCH}/$0/playbook.yaml" -e 'ansible_python_interpreter=/usr/bin/python2'
fi
