#!/bin/bash

AZ_USER_NAME=${1}
AZ_USER_PASSWORD=${2}
AZ_TENANT_ID=${3}
AZ_SUBSCRIPTION_ID=${4}
SP_NAME=${5}
SP_SECRET=${6}
SP_OBJECT_ID=${7}
SP_APP_ID=${8}

echo "`date` --BEGIN-- Provision Stage 1 Script" >>/root/provision-script-output.log
echo "********************************************************************************************"
	echo "`date` -- Setting Time Zone" >>/root/provision-script-output.log
	echo "`date`" >>/root/provision-script-output.log
	timedatectl set-timezone America/New_York >>/root/provision-script-output.log
	echo "`date`" >>/root/provision-script-output.log
echo "********************************************************************************************"
	echo "`date` -- Setting Student User password to 'Microsoft'" >>/root/provision-script-output.log
	echo "Microsoft" | passwd --stdin student
echo "********************************************************************************************"
	echo "`date` -- Adding student to wheel group for sudo access'" >>/root/provision-script-output.log
	usermod -G wheel student
echo "********************************************************************************************"
	echo "`date` -- Setting Root Password to 'Microsoft'" >>/root/provision-script-output.log
	echo "Microsoft" | passwd --stdin root
echo "********************************************************************************************"
	echo "`date` -- Adding 'deltarpm' and other required RPMs" >>/root/provision-script-output.log
	yum -y install deltarpm >> /root/yum-output.log
	wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	yum -y localinstall epel-release-latest-7.noarch.rpm >> /root/yum-output.log
	yum -y install policycoreutils-python libsemanage-devel gcc gcc-c++ kernel-devel python-devel libxslt-devel libffi-devel openssl-devel python2-pip iptables-services git >> /root/yum-output.log
echo "********************************************************************************************"
	echo "`date` -- Securing host and changing default SSH port to 2112" >>/root/provision-script-output.log
	sed -i "s/dport 22/dport 2112/g" /etc/sysconfig/iptables
	semanage port -a -t ssh_port_t -p tcp 2112
	sed -i "s/#Port 22/Port 2112/g" /etc/ssh/sshd_config
	systemctl restart sshd
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl mask firewalld
	systemctl enable iptables
	systemctl start iptables	
echo "********************************************************************************************"	
	echo "`date` -- Installing the Azure Linux CLI" >>/root/provision-script-output.log
	rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
	yum -y install azure-cli >> /root/yum-output.log
echo "********************************************************************************************"	
	echo "`date` -- Adding package elements to enable graphical interface" >>/root/provision-script-output.log
	yum -y groupinstall "Server with GUI" >> /root/yum-output.log
echo "********************************************************************************************"
	echo "`date` -- Setting default systemd target to graphical.target" >>/root/provision-script-output.log
	systemctl set-default graphical.target >> /root/provision-script-output.log
echo "********************************************************************************************"
	echo "`date` -- Installing noVNC environment" >>/root/provision-script-output.log
	yum -y install novnc python-websockify numpy tigervnc-server >> /root/yum-output.log
        wget --quiet -P /etc/systemd/system https://raw.githubusercontent.com/stuartatmicrosoft/RedHatSummit2019/master/provision-scripts/websockify.service
	wget --quiet --no-check-certificate -P /etc/systemd/system "https://raw.githubusercontent.com/stuartatmicrosoft/RedHatSummit2019/master/provision-scripts/vncserver@:4.service"
	openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/pki/tls/certs/novnc.pem -out /etc/pki/tls/certs/novnc.pem -days 365 -subj "/C=US/ST=Michigan/L=Ann Arbor/O=Lift And Shift/OU=AzureAnsible/CN=itscloudy.af"
	su -c "mkdir .vnc" - student
	wget --quiet --no-check-certificate -P /home/student/.vnc https://raw.githubusercontent.com/stuartatmicrosoft/RedHatSummit2019/master/provision-scripts/passwd
        chown student:student /home/student/.vnc/passwd
        chmod 600 /home/student/.vnc/passwd
	iptables -I INPUT 1 -m tcp -p tcp --dport 6080 -j ACCEPT
	service iptables save
        systemctl daemon-reload
        systemctl enable vncserver@:4.service
        systemctl enable websockify.service
        systemctl start vncserver@:4.service
	systemctl start websockify.service
echo "********************************************************************************************"
        echo "`date` -- Upgrading PIP and installing Ansible" >>/root/provision-script-output.log
        pip install --upgrade pip >> /root/pip-output.log
        pip install --upgrade python-dateutil >> /root/pip-output.log
        yum -y remove pyOpenSSL rhn-check rhn-client-tools rhn-setup rhn-setup-gnome rhnlib rhnsd yum-rhn-plugin >>/root/yum-output.log
        pip install pyOpenSSL >> /root/pip-output.log
        pip install ansible==2.7.9 >> /root/pip-output.log
echo "********************************************************************************************"
	echo "`date` -- Editing student's .bashrc and disabling Red Hat alerts" >> /root/provision-script-output.log
	echo " " >> /home/student/.bashrc
        echo "# Azure Service Principal Credentials" >> /home/student/.bashrc
	echo "export AZURE_CLIENT_ID=" >> /home/student/.bashrc
	echo "export AZURE_SECRET=" >> /home/student/.bashrc
	echo "export AZURE_SUBSCRIPTION_ID=" >> /home/student/.bashrc
	echo "export AZURE_TENANT=" >> /home/student/.bashrc
        su -c "gconftool-2 -t bool -s /apps/rhsm-icon/hide_icon true" - student

echo "`date` --END-- Provisioning" >>/root/provision-script-output.log

echo "`date` Creating Student Desktop Credentials File" >>/root/provision-script-output.log

echo AZ_USER_NAME=$AZ_USER_NAME >> /home/student/Desktop/credentials.txt
echo AZ_USER_PASSWORD=$AZ_USER_PASSWORD >> /home/student/Desktop/credentials.txt
echo AZ_TENANT_ID=$AZ_TENANT_ID >> /home/student/Desktop/credentials.txt
echo AZ_SUBSCRIPTION_ID=$AZ_SUBSCRIPTION_ID >> /home/student/Desktop/credentials.txt
echo SP_NAME=$SP_NAME >> /home/student/Desktop/credentials.txt
echo SP_SECRET=$SP_SECRET >> /home/student/Desktop/credentials.txt
echo SP_OBJECT_ID=$SP_OBJECT_ID >> /home/student/Desktop/credentials.txt
echo SP_APP_ID=$SP_APP_ID >> /home/student/Desktop/credentials.txt
echo GUIDE_URL=https://github.com/stuartatmicrosoft/RedHatSummit2019 >> /home/student/Desktop/credentials.txt
chown student:student /home/student/Desktop/credentials.txt

echo "`date` --END-- Provision Script" >>/root/provision-script-output.log
