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

dnf module list nodejs &>> $LOGS_FILE
VALIDATE $? "Module list of nodejs"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enable nodejs:20 version"

dnf list installed nodejs &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    echo "nodejs is  not installed, installing now" | tee -a $LOGS_FILE
    dnf install nodejs -y &>> $LOGS_FILE
    VALIDATE $? "Installing nodejs"
else
    echo -e "nodejs is already installed, $Y SKIPPING $N" | tee -a $LOGS_FILE
fi

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then 
echo "System user is not creatde, Now creating system user"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "Adding System User"
else
    echo -e "System user is already created, $Y SKIPPING $N"


mkdir /app &>> $LOGS_FILE
VALIDATE $? "Creating directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloding code from s3 location"

cd /app &>> $LOGS_FILE
VALIDATE $? "change directory to app"

unzip /tmp/catalogue.zip &>> $LOGS_FILE
VALIDATE $? "unzip the code"

cd /app 
VALIDATE $? "change directory to app"

npm install &>> $LOGS_FILE
VALIDATE $? "read form index.json and installing depenencies using npm build tool"

cp catalogue.service /etc/systemd/system/catalogue.service/ &>> $LOGS_FILE
VALIDATE $? "copying the catalogue service and updated mongodb DNS record"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "daemon-reloaded"

 