#!/bin/bash
r="\[31m"
g="\[32m"
y="\[33m"
b="\[34m"
m="\[35m"
n="\[0m"

USERID=$(id -u)
LOGS_FOLDER="/var/log/roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script execution started at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
  echo -e "${r}You should be a root user to execute this script${n}"
  exit 1
fi

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "${r}$2 is failed, please check the log file for more information: $LOG_FILE${n}"
    exit 1
  else
    echo -e "${g}$2 is completed successfully${n}"
  fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo file"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongoDB"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enabling mongoDB service"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "starting mongoDB service"  

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connection"

systemctl restart mongod
VALIDATE $? "restarting mongoDB service"
