## 題目1 建立 laravel站台 (php-7.4, mysql 5.7, nginx:latest)
centos 7 預先安裝 docker & docker-compose，直接執行smartcloud-laravel-lemp.sh

smartclouds-laravel-lemp目錄內有 Dockerfile / docker-compose.yml /nginx設定
PC上修改c:/windows/system32/drivers/etc/hosts，對應IP smartclouds.site

## 題目2 database 
```
cd ~
git clone https://github.com/datacharmer/test_db.git db
mysql -u root -p < ~/db/employees.sql
```
執行backup-mysql.sh，建立備份目錄/project/backup-db，並產出每個schema.tar.gz
最後刪除>10天檔案 (-type f)

script內使用 for...in 抓取每個schema name執行備份，並未使用sed
參考了https://ericlondon.com/2010/08/25/using-awk-grep-sed-and-mysqldump-to-script-and-backup-your-mysql-databases-on-the-command-line.html
但執行結果失敗

## 題目3 Restful API
不會寫程式

