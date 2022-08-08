COMPONENT=mongodb
source common.sh

echo Setup YUM repo
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG}
StatusCheck

echo Install mongodb
yum install -y mongodb-org &>>${LOG}
StatusCheck

echo Start mongodb service
systemctl enable mongod &>>${LOG} && systemctl start mongod &>>${LOG}
StatusCheck

#update the listen config 127.0.0.0 to 0.0.0.0

DOWNLOAD

echo "Extract the schema files"
cd /tmp && rm -rf mongodb && unzip -o mongodb.zip &>>${LOG}
StatusCheck

echo Load Schema
cd mongodb-main && mongo < catalogue.js &>>${LOG} && mongo < users.js &>>${LOG}
StatusCheck
