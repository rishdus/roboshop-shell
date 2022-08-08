COMPONENT=redis
source common.sh

echo Setup YUM repo
 curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>${LOG}
 StatusCheck

 echo Install Redis
 yum install redis-6.2.7 -y &>>${LOG}
 StatusCheck

#update listen ip
echo start Redis service
 systemctl enable redis &>>${LOG} &&  systemctl restart redis &>>${LOG}
 StatusCheck
