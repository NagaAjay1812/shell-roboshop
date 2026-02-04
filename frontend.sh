#!/bin/bash
USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"
SCRIPT_DIR=$PWD

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

dnf module list nginx &>> $LOGS_FILE
VALIDATE $? "Module list of nginx"


dnf module enable nginx:1.24 -y &>> $LOGS_FILE
VALIDATE $? "Enable nginx:24 version"

dnf list installed nginx &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    echo "nginx is  not installed, installing now" | tee -a $LOGS_FILE
    dnf install ginx -y &>> $LOGS_FILE
    VALIDATE $? "Installing nginx"
else
    echo -e "nginx is already installed, $Y SKIPPING $N" | tee -a $LOGS_FILE
fi

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove the default html content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloding code from s3 location"

cd /usr/share/nginx/html &>> $LOGS_FILE
VALIDATE $? "change directory to html"

unzip /tmp/frontend.zip &>> $LOGS_FILE 
VALIDATE $? "unzip the code"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying the nginx conf and update DNS records"

systemctl restart nginx 
VALIDATE $? "Restart nginx"

