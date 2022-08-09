# this script is only for DRY

StatusCheck() {
  if [ $? -eq 0 ]; then
    echo -e "\e[32mSUCCESS\e[0m"
  else
    echo -e "\e[31mFAILURE\e[0m"
    exit 1
  fi
  }
  DOWNLOAD() {
    echo Downloading ${COMPONENT} application content
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG}
    StatusCheck
  }
APP_USER_SETUP(){
    id roboshop &>>${LOG}
    if [ $? -ne 0 ]; then
     echo Adding application User
       useradd roboshop &>>${LOG}
      StatusCheck
    fi
}
APP_CLEAN(){
   echo Cleaning old application content
   cd /home/roboshop &>>${LOG} && rm -rf ${COMPONENT} &>>${LOG}
    StatusCheck

    echo Extracting application archive
    unzip -o /tmp/${COMPONENT}.zip &>>${LOG} && mv ${COMPONENT}-main ${COMPONENT} &>>${LOG} && cd ${COMPONENT} &>>${LOG}
    StatusCheck

}
SYSTEMD(){

  echo Update systemd config
  sed -i -e 's/MONGO_DNSNAME/mongodb-dev.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis-dev.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue-dev.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb-dev.roboshop.internal/' -e 's/AMQPHOST/rabbitmq-dev.roboshop.internal/' -e 's/CARTHOST/cart-dev.roboshop.internal/' -e 's/USERHOST/user-dev.roboshop.internal/' -e 's/CARTENDPOINT/cart-dev.roboshop.internal/' -e 's/DBHOST/mysql-dev.roboshop.internal/' -e 's/AMQP_HOST/rabbitmq-dev.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>${LOG}
  StatusCheck

  echo configuring ${COMPONENT} systemd service
    mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG} && systemctl daemon-reload &>>${LOG}
    StatusCheck

    echo starting ${COMPONENT} service
    systemctl restart ${COMPONENT} &>>${LOG} && systemctl enable ${COMPONENT} &>>${LOG}
    StatusCheck
}
NODEJS() {
  echo Setting nodejs repos
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  StatusCheck

  echo Installing Nodejs
  yum install nodejs -y &>>${LOG}
  StatusCheck

  APP_USER_SETUP
  DOWNLOAD
  APP_CLEAN

  echo Installing Nodejs dependencies
  npm install &>>${LOG}
  StatusCheck
  
  SYSTEMD
}

JAVA() {

  echo Install maven
  yum install maven -y &>>${LOG}
  StatusCheck

 APP_USER_SETUP
 DOWNLOAD
 APP_CLEAN

 echo Make Application package
  mvn clean package &>>${LOG} && mv target/shipping-1.0.jar shipping.jar &>>${LOG}
  StatusCheck

 SYSTEMD
}

PYTHON() {
  echo Install Python
  yum install python36 gcc python3-devel -y &>>${LOG}
  StatusCheck

   APP_USER_SETUP
   DOWNLOAD
   APP_CLEAN

 echo Install Python dependencies
  cd /home/roboshop/payment && pip3 install -r requirements.txt &>>${LOG}
  StatusCheck

 SYSTEMD

}

GOLANG() {

  echo Installing Golang
  yum install golang -y &>>${LOG}
  StatusCheck

  DOWNLOAD

  APP_USER_SETUP

  APP_CLEAN

  echo building Golang dependencies
  go mod init ${COMPONENT} &>>${LOG} && go get &>>${LOG} && go build &>>${LOG}
  StatusCheck

  SYSTEMD

}

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
   echo -e "\e[31m You shuould run this script as sudo or root user \e[0m"
   exit 1
fi

LOG=/tmp/${COMPONENT}.log
rm -f ${LOG}