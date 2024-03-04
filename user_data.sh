#!/bin/bash
#sudo yum update -y
sudo yum install -y nginx
echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
service nginx start