---
title: docker容器反复重启问题排查
date: 2024-01-17
categories: fun
tag: docker
---

# 反复重启的原因

- 加入的 entrypoint或command 导致容器内部原有的启动指令不执行

# 如何排查

- 以php举例：docker inspect php 查看容器 config 中 Cmd 和 Entrypoint
- 看看 Cmd 和 Entrypoint 各执行了什么
- 在自己的 entrypoint或command 加入 Cmd 或 Entrypoint 就可以了

# 举例

- nginx 容器启动时会执行 nginx -g 'daemon off;'
- entrypoint 中定义的命令最后加上 nginx -g 'daemon off;'
- 这样nginx就不会反复自动重启了，另外其他原因导致的容器重启也可以这么排查

```bash
version: "3"
services:

  nginx:
    image: nginx:1.18.0-alpine
    container_name: "nginx"
    restart: always
    ports:
      - "80:80"
      - "443:443"
    environment:
      - TZ=Asia/Shanghai
    depends_on:
      - "php"
      - "redis"
    volumes:
      - "../:/usr/share/nginx/html"
      - "./:/etc/nginx/conf.d"
    entrypoint: >
      /bin/sh -c "
        cd /usr/share/nginx/html;
        if [ ! -e 'install.lock' ]; then
          touch install.lock;
          cp -rf docker/app.php config/app.php;
          cp -rf docker/db.php config/db.php;
          cp -rf docker/local.php config/local.php;
        fi;
        nginx -g 'daemon off;'
      "
    networks:
      - net-mall

```

