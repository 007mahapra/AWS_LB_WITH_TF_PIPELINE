#!/bin/bash
#sudo yum update -y
sudo yum install -y nginx
service nginx start
echo "<h1>Hello from Mahaveer's Nginx Web Server running at $(hostname -f)</h1>" > /var/www/html/index.html