#!/bin/bash
USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $LOGS_FOLDER

if [ $USERID -ne 0 ]; then
    echo "$R please run the script with root user access. $N" | tee -a $LOGS_FILE
    exit 1
fi


VALIDATE(){ 
    if [ $1 -ne 0 ]; then
        echo -e "$2..... $R Failure $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2..... $G Success $N" | tee -a $LOGS_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/
VALIDATE $? "Copying mongo repo"

dnf list installed mongodb
if [ $? -ne 0 ]; then
    dnf install mongodb-org -y 
    VALIDATE $? "Installing mongoDB server" &>> $LOGS_FILE
else
    echo "mongoDB is already installed $Y SKIPPED $N"
fi

systemctl enable mongod 
VALIDATE $? "start mongoDB" &>> $LOGS_FILE

systemctl start mongod 
VALIDATE $? "enable the mongoDB" &>> $LOGS_FILE

sed - i '/s/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGS_FILE
VALIDATE $? "Allowing the remote access"

systemctl restart mongod &>> $LOGS_FILE
VALIDATE $? "Restart mongoDB"






