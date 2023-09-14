#!/bin/bash

sudo yum update -y
sudo yum install -y httpd
chmod -R 777 /var/www/html
sudo systemctl start httpd
sudo systemctl enable httpd
sudo bash -c 'echo your very first web server > /var/www/html/index.html'