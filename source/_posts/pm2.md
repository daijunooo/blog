---
title: pm2配置文件示例
date: 2021-12-20
categories: fun
tag: docker
---


# laravel队列使用配置文件示例

``` php
{
    "apps": [
        {
            "name": "app-dev-quick",
            "script": "artisan",
            "cwd": "/home/www-data/dev/framework",
            "args": [
                "queue:work",
                "--queue=quick",
            ],
            "exec_interpreter": "php",
            "watch": ["application"],
            "exec_mode": "fork",
            "max_memory_restart": "200M",
            "error_file" : "/tmp/logs/app-dev-quick.log",
            "out_file"   : "/tmp/logs/app-dev-quick.log",
            "env": {
                "NODE_ENV": "dev"
            }
        },
        {     
            "name": "pm2",         
            "script": "/home/www-data/pm2-webui/src/app.js",
            "cwd": "/home/www-data/pm2-webui",
            "exec_interpreter": "node",
            "exec_mode": "fork",      
            "max_memory_restart": "200M",
            "env": {                                  
                "NODE_ENV": "pm2"                  
            }
        }
    ]
}
```