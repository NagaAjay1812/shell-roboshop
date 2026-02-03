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


dnf list installed mysql-server &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    echo " MySQL is not installed, installing now" | tee -a $LOGS_FILE
    dnf install mysql-server -y &>> $LOGS_FILE
    VALIDATE $? "Installing MySQL"
else
    echo -e "MySQL is already installed $Y SKIPPING $N" | tee -a $LOGS_FILE
fi

systemctl enable mysqld &>> $LOGS_FILE
VALIDATE $? "Enable MySQL service" 

systemctl start mysqld &>> $LOGS_FILE
VALIDATE $? "Start MySQL service" 

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGS_FILE
VALIDATE $? "Updated the root password"


