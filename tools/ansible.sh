#!/bin/bash

COOKBOOK_PATH=/tmp/codio_playbook

if test -z "${BRANCH}"; then
    BRANCH=master
fi


CODENAME=$(lsb_release -c -s)

is_core() {
    grep -qFx 'ID=ubuntu-core' /etc/os-release
}

is_classic() {
    ! is_core
}

is_ubuntu_ge() {
    is_classic && compare_ubuntu "${1:-}" "-ge"
}

compare_ubuntu() {
    VERSION=$1
    OPERAND=$2

    if [ -z "$VERSION" ]; then
        echo "os.query: version id is expected"
        exit 1
    fi

    if ! grep -q 'ID=ubuntu' /etc/os-release; then
        echo "os.query: comparing non ubuntu system"
        return 1
    fi

    NUM_RE='^[0-9]+$'
    NUM_VERSION="$(echo "$VERSION" | tr -d '".')"
    if ! [[ $NUM_VERSION =~ $NUM_RE ]] ; then
       echo "os.query: invalid version format \"$VERSION\" provided"
       exit 1
    fi

    SYS_VERSION="$(grep 'VERSION_ID' /etc/os-release)"
    SYS_VERSION="$(echo "${SYS_VERSION#*=}" | tr -d '".')"
    if ! [[ $SYS_VERSION =~ $NUM_RE ]] ; then
       echo "os.query: invalid version format \"$SYS_VERSION\" retrieved from system"
       exit 1
    fi

    test "$SYS_VERSION" "$OPERAND" "$NUM_VERSION"
}

is_ubuntu_ge_22_04() {
    is_ubuntu_ge "22.04"
}

PY_FLAG=$1

IS_TRUSTY() { [ "${CODENAME}" == "trusty" ]; }
IS_XENIAL() { [ "${CODENAME}" == "xenial" ]; }
IS_BIONIC() { [ "${CODENAME}" == "bionic" ]; }
IS_JAMMY() { [ "${CODENAME}" == "jammy" ]; } # 22.04
IS_RESOLUTE() { [ "${CODENAME}" == "resolute" ]; } # 26.04
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
if IS_RESOLUTE; then
    ansible --version | grep -q '2.20' 2> /dev/null
    is_ansible_right=$?
fi

if [ $is_ansible_right -ne 0 ]; then
    do_cmd sudo apt-get update
    if USE_PYTHON3; then
      do_cmd sudo apt-get -y install python3 python3-apt python3-pip
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
    if is_ubuntu_ge_22_04; then
        do_cmd sudo apt update
        do_cmd sudo apt install -y ansible
    else
        do_cmd sudo dpkg -i /tmp/ansible.deb
        do_cmd sudo rm /tmp/ansible.deb
    fi
fi

download_playbook

do_cmd sudo apt-get update

if USE_PYTHON3 || is_ubuntu_ge_22_04; then
    sudo ansible-playbook -v "${COOKBOOK_PATH}/install_software-${BRANCH}/$0/playbook.yaml" -e 'ansible_python_interpreter=/usr/bin/python3'
elif IS_TRUSTY; then
    sudo ansible-playbook -v "${COOKBOOK_PATH}/install_software-${BRANCH}/$0/playbook.yaml"
else
    sudo ansible-playbook -v "${COOKBOOK_PATH}/install_software-${BRANCH}/$0/playbook.yaml" -e 'ansible_python_interpreter=/usr/bin/python2'
fi
