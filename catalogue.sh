#!/bin/bash
USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.cloudkarna.in
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

id roboshop &>> $LOGS_FILE   # idempotency: if you perform operation multiple times the end result would be same 
if [ $? -ne 0 ]; then 
echo "System user is not created, now creating system user"         
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "Adding System User"
else
    echo -e "System user is already created, $Y SKIPPING $N"

fi

mkdir -p /app &>> $LOGS_FILE   # if directory is already existed skip to create the direcory again
VALIDATE $? "Creating directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloding code from s3 location"

cd /app &>> $LOGS_FILE
VALIDATE $? "change directory to app"

unzip -o /tmp/catalogue.zip &>> $LOGS_FILE    # o - means overwriting if catalogue is already unzipped it will overwrite those files or you can remove entire app rm -rf /app/*
VALIDATE $? "unzip the code"

cd /app 
VALIDATE $? "change directory to app"

rm -rf node_modules package-lock.json &>> $LOGS_FILE #if modules or dependencies already installed first we will remove again we will install
npm install &>> $LOGS_FILE
VALIDATE $? "read form index.json and installing depenencies using npm build tool"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGS_FILE
VALIDATE $? "copying the catalogue service and updated mongodb DNS record"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "daemon-reloaded"

systemctl enable catalogue &>> $LOGS_FILE
systemctl start catalogue &>> $LOGS_FILE
VALIDATE $? "Enable and start the catalogue service"

cp  $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
VALIDATE $? "cpy the mongo repo"

dnf install mongodb-mongosh -y &>> $LOGS_FILE
VALIDATE $? "Install mongo client"

mongosh --host $MONGODB_HOST </app/db/master-data.js
VALIDATE $? "Connect to mongo DB and Load the master data "

mongosh --host $MONGODB_HOST
VALIDATE $? "Connect to mongo DB"

show dbs
VALIDATE $? "show dbs"

use catalogue
VALIDATE $? "Using catalogue"

show collections
VALIDATE $? "show collections"

db.products.find()
VALIDATE $? "show products"

 