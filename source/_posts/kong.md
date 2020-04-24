---
title: kong 一个高性能网关
date: 2020-04-21
categories: fun
tag: fun
---

# 安装
1. 先安装好 docker，新建 docker-compose.yml 文件，将下面代码粘贴到 docker-compose.yml 里面
2. cd 到 docker-compose.yml 所在目录运行 docker-compose up
3. 百度到的安装方法都太复杂，此方式较为简单快捷，适合懒人，运行结束后访问localhost:8001,返回json表示一切ok

``` php
version: '3'

networks:
  kong-net:

services:
  
  kong:
    image: kong:2.0.0-alpine
    user: kong
    environment:
      KONG_DATABASE: 'off'
      KONG_ADMIN_ACCESS_LOG: /dev/stdout
      KONG_ADMIN_ERROR_LOG: /dev/stderr
      KONG_ADMIN_LISTEN: '0.0.0.0:8001'
      KONG_PROXY_ACCESS_LOG: /dev/stdout
      KONG_PROXY_ERROR_LOG: /dev/stderr
    networks:
      - kong-net
    ports:
      - "8000:8000/tcp"
      - "8001:8001/tcp"
      - "8443:8443/tcp"
      - "8444:8444/tcp"
    healthcheck:
      test: ["CMD", "kong", "health"]
      interval: 10s
      timeout: 10s
      retries: 10
    restart: on-failure
```

> 此模式为无数据库模式

# 日常使用

1. 使用 docker-compose start 启动 kong，前提 cd 到 docker-compose.yml 目录
2. 使用 docker-compose stop 停止 kong 服务

# 一个栗子

1. 创建一个服务


``` php
curl -i -X POST \
  --url http://localhost:8001/services/ \
  --data 'name=baidu' \
  --data 'url=http://baidu.com'
```

2. 创建一个路由和刚刚的服务关联


``` php
curl -i -X POST \
  --url http://localhost:8001/services/baidu/routes \
  --data 'paths[]=/baidu'
```

> 以上请求可以使用接口工具发送

3. 测试网关是否可以成功转发请求

- 浏览器访问 localhost:8000/baidu
- 如果成功访问了百度，说明以上设置成功

4. 以上测试是通过url规则来匹配，kong支持多种方式，有一种是在header头中加入host标识来路由到服务，这种我没有测试成功，如果有人测试通了麻烦告知我一下

# 为什么选kong

- 开源并且基于nginx性能卓越
- 配合kanga可实现可视化操作，多种插件可选，实现服务监控限流熔断等等功能
- 跨语言，任何语言的写的后端服务都可以使用