# this script is only for DRY

StatusCheck() {
  if [ $? -eq 0 ]; then
    echo -e "\e[32mSUCCESS\e[0m"
  else
    echo -e "\e[31mFAILURE\e[0m"
    exit 1
  fi
  }

NODEJS() {
  echo setting nodejs repos
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>/tmp/cart.log
  StatusCheck

  echo installing nodejs
  yum install nodejs -y &>>/tmp/cart.log
  StatusCheck

  id roboshop &>>/tmp/cart.log
  if [ $? -ne 0 ]; then
   echo adding application user
     useradd roboshop &>>/tmp/cart.log
    StatusCheck
  fi
}
