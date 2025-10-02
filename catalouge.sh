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
mongodb_host=mongodb.gopi29.fun

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

################# NodeJS related steps #####################
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling nodejs module"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling nodejs 20 module"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
VALIDATE $? "adding roboshop user"

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "creating application directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading catalogue application code"

cd /app
VALIDATE $? "changing directory to /app"

unzip /tmp/catalogue.zip
VALIDATE $? "extracting catalogue application code"

npm install &>>$LOG_FILE
VALIDATE $? "installing nodejs dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copying catalogue systemd service file"

systemctl daemon-reload
VALIDATE $? "reloading systemd"

systemctl enable catalogue
VALIDATE $? "enabling catalogue service"

systemctl start catalogue
VALIDATE $? "starting catalogue service"

#------------------ MongoDB related steps ------------------#
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo file"

dnf install mongodb-mongosh -y
VALIDATE $? "installing mongoDB shell"

mongosh --host $mongodb_host </app/db/master-data.js
VALIDATE $? "loading catalogue schema"

systemctl restart catalogue
VALIDATE $? "restarting catalogue service"