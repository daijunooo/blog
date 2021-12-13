---
title: docker构建laravel 6.x 队列环境
date: 2021-12-12
tag: docker
---

# 获取php基础镜像

### 拉取基础镜像，选用php:7.4-alpine基础镜像

``` php
docker pull php:7.4-alpine
```

### 生成容器进入容器

``` php
docker run -itd --name php php:7.4-alpine

docker exec -it php sh
```


# 安装npm

### 修改apk镜像源

``` php
//阿里镜像
sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

//科大镜像
sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
```

### 安装npm

- 手动安装npm所需依赖
- 画重点 --virtual，先安装需要的依赖，后面再删掉减小镜像大小

``` php
apk add --no-cache --virtual .npm c-ares libgcc libstdc++ icu-libs libuv nodejs-current
```
- 安装npm

``` php
apk add --no-cache npm
```
- 删除安装npm时安装的依赖,最大限度的减少镜像体积

``` php
apk del .npm
```

# 安装所需php扩展

``` php
docker-php-ext-install pdo_mysql bcmath
```
- 安装redis扩展

``` php
apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS

pecl install -o -f redis

apk del .phpize-deps

rm -rf /tmp/pear

docker-php-ext-enable redis
```


# 打包容器生成新docker镜像

``` php
docker commit -m 'add npm' php php:npm
```
