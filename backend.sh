#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
 
 LOGS_FOLDER="/var/log/expense-logs"
 LOG_FILE=$(echo $0 | cut -d "." -f1)
 TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
 LOG_FILE_NAME="$lOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

 VALIDATE() {
     if [ $1 -ne 0 ]
     then
         echo -e "$2 ... $R FAILED $N"
         exit 1
     else
         echo -e "$2 ... $G SUCCESS $N"
     fi
    
}

CHECK_ROOT() {
     if [ $USERID -ne 0 ]
     then
         echo "ERROR:: You must have sudo access to run this script"
         exit 1
     fi
}
echo "Script started  executing at $TIMESTAMP" &>> $LOG_FILE_NAME

CHECK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling Exesting default NodeJS Module"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling NodeJS:20 Module"

dnf install -y nodejs &>>$LOG_FILE_NAME
VALIDATE $? "Installing NodeJS" 

id expense &>>$LOG_FILE_NAME
if [ $? -nq 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "Adding User Expense"
else
    echo -e "User Expense already exists ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "Creating Directory /app"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading Backend Code"

cd /app

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Extracting Backend Code"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing NodeJS Dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#prepare mysql schema

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.mani82s.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Creating MySQL Schema"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Reloading Systemd Daemon"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "enabling Backend Service"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "Starting Backend Service"




