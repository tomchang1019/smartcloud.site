## 題目1 建立 laravel站台 php-7.4, mysql 5.7, nginx:latest
centos 7 預先安裝 docker & docker-compose，直接執行smartcloud-laravel-lemp.sh

smartclouds-laravel-lemp目錄內有 Dockerfile / docker-compose.yml /nginx設定

## 題目2 database 
```
cd ~
git clone https://github.com/datacharmer/test_db.git db
mysql -u root -p < ~/db/employees.sql
```
執行backup-mysql.sh，建立備份目錄/project/backup-db，並產出每個schema.tar.gz
最後刪除>10天檔案 (-type f)

## 題目3 Restful API
不會寫程式

