---
title: linux实用指令
date: 2023-01-05
categories: fun
tag: linux
---

### 在当前目录以及子目录搜索文件中含有www-data关键词的文件
grep -r -R "www-data" .

### 在根目录以及子目录查找php.ini文件
find / -name php.ini

### 以指定用户运行命令 (以www-data用户运行pm2 start app.json)
su -s /bin/sh -c "pm2 start app.json" www-data

### 挂载目录到其他目录
mount --bind /www/site/master/framework/storage/logs/ ./log_master

### 查找大于1G的文件
find / -type f -size +1024000k -exec du -h {} \;

### 查询当前目录下子目录磁盘空间占用情况
du -h -x --max-depth=1

