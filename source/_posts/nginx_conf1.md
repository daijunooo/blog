---
title: 巧用 nginx 做接口开发
date: 2023-9-14
categories: fun
tag: nginx
---

# 为什么有这篇文章

- 接口开发时总是需要使用各种接口工具来测试代码
- 即使在好用的接口工具也都还是需要人工操作的
- 如果涉及到流程的测试需要调接口很多次，很不方便

# 那怎么办？

- 直接部署一个测试环境不就好了
- 确实可以，但是测出问题改bug依然要在本地
- 能不能线上测试然后指定的接口走本地服务，测出问题即时就可以修复

# 解决方案

- 使用 nginx 反向代理指定接口
- 本机 hosts 中添加线上环境域名指定到本机IP
- 问题来了，如果接口地址和应用域名一样，所有请求都走本地了？ 暂时搁置后面会有办法

### 使用 nginx 反向代理指定接口

``` php
# docker-compose.yml 配置

version: "3"
services:

  # 配置文件目录 /etc/nginx
  nginx:
    image: nginx:1.18.0-alpine
    container_name: "nginx"
    restart: always
    command: ["/bin/sh", "-c", "echo 'nameserver 223.5.5.5' > /etc/resolv.conf && nginx -g 'daemon off;'"]
    ports:
      - "80:80"
      - "443:443"
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - "${WWW}:/www"
      - "./nginx/conf.d:/etc/nginx/conf.d"
    networks:
      - net-app

networks:
  net-app:

# nginx 配置 ./nginx/conf.d/proxy.conf
server {
    listen 80;
    server_name xxx.com;

    location /api/points-mall {
        proxy_pass http://192.168.3.4:8080;
        rewrite ^/api/points-mall(.*) $1 break;
    }

    location / {
        proxy_pass https://xxx.com/;
    }
}

# hosts 文件添加
127.0.0.1    xxx.com
```

# 划重点

- 访问 http://xxx.com 打开线上应用开始测试
- hosts 中添加了 xxx.com 记录，那 proxy_pass https://xxx.com/; 又代理到本机形成死循环
- 假如反向代理时能忽略本地的 hosts 文件不就可以了
- command: ["/bin/sh", "-c", "echo 'nameserver 223.5.5.5' > /etc/resolv.conf && nginx -g 'daemon off;'"] 这行就是可以让 nginx 反向代理忽略本机的 hosts

# 总结

- 此方案适用于快速修复bug
- 大大简化开发和测试
- 拓展此方案可以实现接口在不同服务中
- 微服务的本地测试可以使用此方案