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
        echo -e "$2.....$R Failure $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2.....$G Success $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable redis -y &>> $LOGS_FILE
dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "Disable the default version of redis and enable the version:7 "

dnf list installed redis &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    dnf install redis -y  &>> $LOGS_FILE
    VALIDATE $? "Installing redis server" 
else
    echo -e "redis is already installed $Y SKIPPED $N" | tee -a $LOGS_FILE
fi

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>> "$LOGS_FILE"
VALIDATE $? "Allowing the remote connection"

systemctl enable redis &>> $LOGS_FILE
systemctl start redis &>> $LOGS_FILE
VALIDATE $? "Enable and start redis service" 








