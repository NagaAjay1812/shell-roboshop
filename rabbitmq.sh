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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOGS_FILE
VALIDATE $? "copying the rabbitmq repo"

dnf list installed rabbitmq-server &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    dnf install rabbitmq-server -y  &>> $LOGS_FILE
    VALIDATE $? "Installing rabbitmq server" 
else
    echo -e "rabbitmq is already installed $Y SKIPPED $N" | tee -a $LOGS_FILE
fi

systemctl enable rabbitmq-server &>> $LOGS_FILE
VALIDATE $? "Enable rabbitmq service" 

systemctl start rabbitmq-server &>> $LOGS_FILE
VALIDATE $? "Start rabbitmq  service" 

id roboshop &>> $LOGS_FILE   # idempotency: if you perform operation multiple times the end result would be same 
if [ $? -ne 0 ]; then 
echo "System user is not created, now creating system user"         
    rabbitmqctl add_user roboshop roboshop123 &>> $LOGS_FILE
    VALIDATE $? "Adding System User"
else
    echo -e "System user is already created, $Y SKIPPING $N"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "set the permission"