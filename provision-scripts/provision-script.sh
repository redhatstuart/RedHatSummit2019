#!/bin/bash

echo "`date` --BEGIN-- Provision Stage 1 Script" >>/root/lsprovision.log
echo "********************************************************************************************"
	echo "`date` -- Setting Student User password to 'Microsoft'" >>/root/lsprovision.log
	echo "Microsoft" | passwd --stdin student
echo "********************************************************************************************"
	echo "`date` -- Adding student to wheel group for sudo access'" >>/root/lsprovision.log
	usermod -G wheel student
echo "********************************************************************************************"
	echo "`date` -- Setting Root Password to 'Microsoft'" >>/root/lsprovision.log
	echo "Microsoft" | passwd --stdin root
echo "********************************************************************************************"
	echo "`date` -- Adding 'deltarpm' and other required RPMs" >>/root/lsprovision.log
	yum -y install deltarpm
	wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	yum -y localinstall epel-release-latest-7.noarch.rpm
	yum -y install policycoreutils-python libsemanage-devel gcc gcc-c++ kernel-devel python-devel libxslt-devel libffi-devel openssl-devel python2-pip iptables-services git
echo "********************************************************************************************"
	echo "`date` -- Securing host and changing default SSH port to 2112" >>/root/lsprovision.log
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
	echo "`date` -- Adding package elements to enable graphical interface" >>/root/lsprovision.log
	yum -y groupinstall "Server with GUI"
echo "********************************************************************************************"
	echo "`date` -- Setting default systemd target to graphical.target" >>/root/lsprovision.log
	systemctl set-default graphical.target
echo "********************************************************************************************"
	echo "`date` -- Installing noVNC environment" >>/root/lsprovision.log
	yum -y install novnc python-websockify numpy tigervnc-server
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
echo "`date` --END-- Provision Stage 1 Script" >>/root/lsprovision.log
