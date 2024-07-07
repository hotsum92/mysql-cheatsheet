#!/bin/bash -ue

docker run --rm --name mysql -v mysql-data:/var/lib/mysql -p 3307:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql:8.0
