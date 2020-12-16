---
title: kong 网关鉴权实践
date: 2020-12-16
categories: fun
tag: fun
---

# 安装kong+konga

``` php
version: "3"
 
networks:
 kong-net:
  driver: bridge
 
services:
 
  #######################################
  # Postgres: The database used by Kong
  #######################################
  kong-database:
    image: postgres:9.6
    restart: always
    networks:
      - kong-net
    environment:
      POSTGRES_USER: kong
      POSTGRES_DB: kong
      POSTGRES_PASSWORD: kong
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "kong"]
      interval: 5s
      timeout: 5s
      retries: 5
 
  #######################################
  # Kong database migration
  #######################################
  kong-migration:
    image: kong:latest
    command: "kong migrations bootstrap"
    networks:
      - kong-net
    restart: on-failure
    environment:
      - KONG_DATABASE=postgres
      - KONG_PG_HOST=kong-database
      - KONG_PG_DATABASE=kong
      - KONG_PG_PASSWORD=kong
    depends_on:
      - kong-database
 
  #######################################
  # Kong: The API Gateway
  #######################################
  kong:
    image: kong:latest
    restart: always
    networks:
      - kong-net
    environment:
      KONG_DATABASE: postgres
      KONG_PG_HOST: kong-database
      KONG_PG_PASSWORD: kong
      KONG_PROXY_LISTEN: 0.0.0.0:8000
      KONG_PROXY_LISTEN_SSL: 0.0.0.0:8443
      KONG_ADMIN_LISTEN: 0.0.0.0:8001
    depends_on:
      - kong-migration
    healthcheck:
      test: ["CMD", "curl", "-f", "http://kong:8001"]
      interval: 5s
      timeout: 2s
      retries: 15
    ports:
      - "8001:8001"
      - "8000:8000"
      - "8443:8443"
 
  #######################################
  # Konga database prepare
  #######################################
  konga-prepare:
    image: pantsel/konga:latest
    command: "-c prepare -a postgres -u postgresql://kong:kong@kong-database:5432/konga"
    networks:
      - kong-net
    restart: on-failure
    environment:
      - KONG_DATABASE=postgres
      - KONG_PG_HOST=kong-database
      - KONG_PG_DATABASE=konga
      - KONG_PG_PASSWORD=kong
    depends_on:
      - kong-database
 
  #######################################
  # Konga: Kong GUI
  #######################################
  konga:
    image: pantsel/konga:latest
    restart: always
    networks:
     - kong-net
    environment:
      DB_ADAPTER: postgres
      DB_URI: postgresql://kong:kong@kong-database:5432/konga
      NODE_ENV: production
    depends_on:
      - kong
      - konga-prepare
    ports:
      - "1337:1337"
```

- 复制上面代码保存为 docker-compose.yml
- 执行docker-compose up,安装kong和konga
- 启动kong，docker-compose start，进入后台管理http://127.0.0.1:1337

# 配置kong网关到konga

- 点击Connections 菜单，点击NEW CONNECTION
- 在DEFAULT卡片下，name随意，Kong Admin URL中输入http://kong:8001。
- 等待片刻查看结果

# 添加一个服务（SERVICES）

- 点击SERVICES菜单，点击ADD NEW SERVICE
- Url中输入https://www.baidu.com/,点击确定

# 添加一个路由（ROUTES）

- 点击刚刚添加的服务，点击详情页的Routes,点击ADD ROUTE
- Hosts里输入localhost，输入完记得一定要敲一下回车
- Paths输入/baidu，也需要敲回车
- Protocols里输入http，继续敲一下回车
- 保存

> 到这里所有准备工作就完成了，可以输入http://localhost:8000/baidu,看看是否可以访问百度

# 添加jwt插件

- 点击PLUGINS菜单，点击ADD GLOBAL PLUGINS，选择Jwt
- uri param names里面填token，然后敲一下回车
- key claim name里面填client_id,同上敲一下回车
- claims to verify里面填exp，同上
- header names里面填token，同上
- 完成

# 添加一个消费者

- 点击CONSUMERS菜单，点击CREATE CONSUMER，起个名字后保存

# 配置jwt

- 点击刚才添加的消费者
- 在Credentials卡片里面点JWT
- 点击CREATE JWT
- key里面填dev-client
- 点击确定完成

# 测试jwt

- 访问 http://localhost:8000/baidu 看看是否需要验证
- 如果需要验证进入 https://jwt.io/
- your-256-bit-secret 里面输入kong后台jwt的secret
- 下面代码输入到PAYLOAD:DATA里面

``` php
{
  "client_id": "dev-client",
  "exp": 1516239022
}
```

- 复制左边框中的token后访问百度，加入token参数
- 例如 http://localhost:8000/baidu?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGllbnRfaWQiOiJkZXYtY2xpZW50IiwiZXhwIjoxNTE2MjM5MDIyfQ.ObAlmfqSQaOltVNUjWVe4B4u5RnKWKZ4akv4hkg5AwI
- 如果成功访问百度了就验证通过了

# 意义

- 以后所有的微服务都可以用kong来做网关，统一管理
- kong的很多插件如限流熔断等等可以更好的管理服务
- 所有的微服务都不需要关心用户鉴权了，只需要关心业务就ok了
