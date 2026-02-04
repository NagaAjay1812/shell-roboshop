#!/bin/bash
USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.cloudkarna.in

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

dnf list installed maven &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    echo "maven is  not installed, installing now" | tee -a $LOGS_FILE
    dnf install maven -y &>> $LOGS_FILE
    VALIDATE $? "Installing maven"
else
    echo -e "maven is already installed, $Y SKIPPING $N" | tee -a $LOGS_FILE
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

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloding code from s3 location"

cd /app &>> $LOGS_FILE
VALIDATE $? "change directory to app"

unzip -o /tmp/shipping.zip &>> $LOGS_FILE    # o - means overwriting if user is already unzipped it will overwrite those files or you can remove entire app rm -rf /app/*
VALIDATE $? "unzip the code"

cd /app 
VALIDATE $? "change directory to app"

mvn clean package 
mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Installe dependencies, build application, moving $ renaming shpping file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>> $LOGS_FILE
VALIDATE $? "copying the shipping service and updated mysql and cart DNS record"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "daemon-reloaded"

systemctl enable user &>> $LOGS_FILE
systemctl start user &>> $LOGS_FILE
VALIDATE $? "Enable and start the shipping service"

dnf install mysql -y  &>> $LOGS_FILE
VALIDATE $? "Install MySQL client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE
    VALIDATE $? "Loaded data into MySQL"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi

systemctl enable shipping &>>$LOGS_FILE
systemctl start shipping
VALIDATE $? "Enabled and started shipping"