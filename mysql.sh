COMPONENT=mysql
source common.sh

if [ -z "$MYSQL_PASSWORD"]; then
  echo "\e[33m env variable MYSQL_PASSWORD is missing \e[0m"
  exit 1
fi


echo Install YUM repo
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG}
StatusCheck

echo Install mysql
yum install mysql-community-server -y &>>${LOG}
StatusCheck

echo Start Mysql Service
systemctl enable mysqld &>>${LOG} && systemctl start mysqld &>>${LOG}
StatusCheck

DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')


echo "alter user 'root'@'localhost' identified with mysql_native_password by '$MYSQL_PASSWORD';" | mysql --connect-expired-password -uroot -p${DEFAULT_PASSWORD}

 echo "uninstall plugin validate_password;" | mysql -uroot -p$MYSQL_PASSWORD

#> uninstall plugin validate_password;

curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"

cd /tmp
rm -rf mysql
unzip -o mysql.zip
cd mysql-main
mysql -u root -pRoboShop@1 <shipping.sql