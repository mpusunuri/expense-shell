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

dnf install -y mysql-server &>> $LOG_FILE_NAME
VALIDATE $? "Installing MySQL Server"   

systemctl enable --now mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Starting MySQL Server"

mysql_secure_installation --set-root-pass ExpenseApp@1 -e 'show databases'; &>> $LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo "mysql Root Password not set up" &>> $LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting Root Password"

else
    echo -e "mysql Root Password already set up ... &Y SKIPPING &N"
fi
