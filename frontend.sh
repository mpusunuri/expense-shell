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

mkdir -p $LOGS_FOLDER
echo "Script started  executing at $TIMESTAMP" &>> $LOG_FILE_NAME

CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "Removing Default Nginx Content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading Index Page"

cd /usr/share/nginx/html
VALIDATE $? "moving to HTML directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Extracting Frontend Code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
VALIDATE $? "Copying expense Configuration"

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "Restarting Nginx"