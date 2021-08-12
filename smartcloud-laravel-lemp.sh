## you need git and docker installed at centos7 to run this script 
## run it with a non-root account which has sudo privilege 

#!/bin/bash

cd ~

git clone https://github.com/laravel/laravel.git laravel-web
cd ~/laravel-web
docker run --rm -v $(pwd):/app composer install
sudo chown -R $USER:$USER ~/laravel-web

## docker-compose.yml

cat << EOF > ~/laravel-web/docker-compose.yml
version: '3.8'
services:

#PHP Service
 app:
  build:
   context: .
   dockerfile: Dockerfile
  image: mylab
  container_name: app
  restart: unless-stopped
  tty: true
  environment:
   SERVICE_NAME: app
   SERVICE_TAGS: dev
   working_dir: /var/www/html/
  volumes:
   - ./:/var/www/html/
   - ./php/laravel.ini:/usr/local/etc/php/conf.d/laravel.ini
  networks:
   - app-network

 #Nginx Service
 webserver:
  image: nginx
  container_name: webserver
  restart: unless-stopped
  privileged: true
  tty: true
  ports:
   - "80:80"
   - "443:443"
  volumes:
   - ./:/var/www/html/
   - ./nginx/conf.d/:/etc/nginx/conf.d/
   - ./nginx-log:/var/log/nginx
  networks:
   - app-network

 #MySQL Service
 db:
  image: mysql:5.7.32
  container_name: db
  restart: unless-stopped
  tty: true
  ports:
   - "3306:3306"
  environment:
   MYSQL_DATABASE: laravel_web
   MYSQL_ROOT_PASSWORD: Aa-123456789
   SERVICE_TAGS: dev
   SERVICE_NAME: mysql
  volumes:
   - dbdata:/var/lib/mysql/
   - ./mysql/my.cnf:/etc/mysql/my.cnf
  networks:
   - app-network

#Docker Networks
networks:
 app-network:
  driver: bridge
#Volumes
volumes:
 dbdata:
  driver: local
EOF

## Dockerfile

cat << EOF > ~/laravel-web/Dockerfile
FROM php:7.4-fpm

# Copy composer.lock and composer.json into the working directory
COPY composer.lock composer.json /var/www/html/

# Set working directory
WORKDIR /var/www/html/

# Install dependencies for the operating system software
RUN apt-get update

RUN apt-get install -y build-essential libpng-dev libjpeg62-turbo-dev libfreetype6-dev locales zip jpegoptim optipng pngquant gifsicle vim libzip-dev unzip git libonig-dev curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions for php
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Install composer (php package manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy existing application directory contents to the working directory
COPY . /var/www/html

# Assign permissions of the working directory to the www-data user
RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 9000 and start php-fpm server (for FastCGI Process Manager)
EXPOSE 9000
CMD ["php-fpm"]
EOF

## PHP config
mkdir -p ~/laravel-web/php
cat << EOF > ~/laravel-web/php/laravel.ini
upload_max_filesize=80M
post_max_size=80M
EOF

## Nginx config
mkdir -p ~/laravel-web/nginx/conf.d
mkdir -p ~/laravel-web/nginx-log
cat <<'EOF' > ~/laravel-web/nginx/conf.d/smartcloud.conf
server {
  listen 80;
  index index.php index.html;
  root /var/www/html/public;
  server_name smartclouds.site;

  location / {
   try_files $uri $uri/ /index.php?$query_string;
   gzip_static on;
  }

  location ~ \.php$ {
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass  app:9000;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
  }
}
EOF

## MySQL config
mkdir ~/laravel-web/mysql
cat << 'EOF' > ~/laravel-web/mysql/my.cnf
[mysqld]
general_log = 1
general_log_file = /var/lib/mysql/general.log
EOF

## laravel enviroment variable
cp .env.example .env
sed -i 's+DB_HOST=127.0.0.1+DB_HOST=db+' ~/laravel-web/.env
sed -i 's+DB_DATABASE=laravel+DB_DATABASE=laravel_web+' ~/laravel-web/.env
sed -i 's+DB_USERNAME=laravel+DB_USERNAME=laraveldocker+' ~/laravel-web/.env
sed -i 's+DB_PASSWORD=+DB_PASSWORD=Aa-123456789+' ~/laravel-web/.env

## docker-compose up
docker-compose up -d

## php keygen
docker exec app php artisan key:generate
docker exec app php artisan config:cache

## Create MySQL user laraveldocker & setup permission

cat <<'EOF' > ./laraveldocker.sql
GRANT ALL ON laravel_web.* TO 'laraveldocker'@'%' IDENTIFIED BY 'Aa-123456789';
flush privileges;
EOF

docker exec db mysql -u root -pAa-123456789 < laraveldocker.sql



