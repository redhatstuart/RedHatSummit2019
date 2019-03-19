#!/bin/bash

AZ_USER_NAME=${1}
AZ_USER_PASSWORD=${2}
AZ_TENANT_ID=${3}
AZ_SUBSCRIPTION_ID=${4}
SP_NAME=${5}
SP_SECRET=${6}
SP_OBJECT_ID=${7}
SP_APP_ID=${8}

wget --quiet --no-check-certificate -P /root https://raw.githubusercontent.com/stuartatmicrosoft/Azure-Linux-Migration-Workshop/master/provision-scripts/provision-stage1.sh

chmod 755 /root/provision-script.sh

echo "`date` -- Calling Provision Script" >>/root/lsprovision.log
bash /root/provision-script.sh
echo "`date` -- Provision script complete" >>/root/lsprovision.log

echo AZ_USER_NAME=$AZ_USER_NAME >> /home/student/Desktop/credentials.txt
echo AZ_USER_PASSWORD=$AZ_USER_PASSWORD >> /home/student/Desktop/credentials.txt
echo AZ_TENANT_ID=$AZ_TENANT_ID >> /home/student/Desktop/credentials.txt
echo AZ_SUBSCRIPTION_ID=$AZ_SUBSCRIPTION_ID >> /home/student/Desktop/credentials.txt
echo SP_NAME=$SP_NAME >> /home/student/Desktop/credentials.txt
echo SP_SECRET=$SP_SECRET >> /home/student/Desktop/credentials.txt
echo SP_OBJECT_ID=$SP_OBJECT_ID >> /home/student/Desktop/credentials.txt
echo SP_APP_ID=$SP_APP_ID >> /home/student/Desktop/credentials.txt
echo GUIDE_URL=https://github.com/stuartatmicrosoft/Azure-Linux-Migration-Workshop >> /home/student/Desktop/credentials.txt
chown student:student /home/student/Desktop/credentials.txt
