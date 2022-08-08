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
  echo configuring ${COMPONENT} systemd service
    mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG} && systemctl daemon-reload &>>${LOG}
    StatusCheck

    echo starting ${COMPONENT} service
    systemctl start ${COMPONENT} &>>${LOG} && systemctl enable ${COMPONENT} &>>${LOG}
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

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
   echo -e "\e[31m You shuould run this script as sudo or root user \e[0m"
   exit 1
fi

LOG=/tmp/${COMPONENT}.log
rm -f ${LOG}