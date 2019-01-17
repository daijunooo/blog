---
title: laradock 搞定php各种环境
date: 2019-01-08
categories: fun
tag: docker
---

# 安装docker
- 百度安装，不是本文重点所以略过

# 获取最新laradock

``` php
git clone https://github.com/laradock/laradock.git
```

# 修改环境参数
1. cd 到克隆下来的 laradock 目录下
2. cp env-example .env
3. 修改 .env 环境参数，例如 PHP_VERSION=7.1 改为 PHP_VERSION=5.6 ，php的版本就变成5.6版本了
4. 修改其他参数为你需要的环境版本

# 构建环境并运行

``` php
docker-compose up -d nginx mysql
```
> 注意：所有Web服务器容器nginx，apache..依赖于php-fpm，这意味着如果您运行其中任何一个，它们将自动php-fpm为您启动容器，因此无需在up命令中明确指定它。

- 至此一个php环境就搭建好了，并且可以自由组合服务器端软件及版本，作为开发环境用也十分方便。

# 常用命令

``` php
//构建环境并使用
docker-compose up -d nginx mysql
//重建环境
docker-compose build workspace
//重建php-fpm
docker-compose build php-fpm
//删除所有现有容器
docker-compose down
//进入当前命令行
docker-compose exec workspace bash
```
- 注意：应该添加--user=laradock（示例docker-compose exec --user=laradock workspace bash）将文件创建为主机用户以防止日志文件的问题所有者将更改为root，然后如果使用旋转日志并且新日志文件不存在则laravel网站无法写入日志文件
- docker-compose命令得进入laradock目录才能执行


[更详细的内容请戳这里](https://laradock.io/)