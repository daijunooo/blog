---
title: nginx配置中的细节
date: 2022-1-7
categories: fun
tag: nginx
---

# 看着挺正常，这里面有不规范的地方

- index index.html index.htm index.php; 这一行应该放到外面，继承关系：Nginx配置文件分为好多块，常见的从外到内依次是「http」、「server」、「location」等等，缺省的继承关系是从外到内
- 很多人喜欢用「if」指令做一系列的检查，不过这实际上是「try_files」指令的职责
- Nginx有两份fastcgi配置文件，分别是「fastcgi_params」和「fastcgi.conf」，它们没有太大的差异，唯一的区别是后者比前者多了一行「SCRIPT_FILENAME」的定义。原本Nginx只有「fastcgi_params」，后来发现很多人在定义「SCRIPT_FILENAME」时使用了硬编码的方式，于是为了规范用法便引入了「fastcgi.conf」。不过这样的话就产生一个疑问：为什么一定要引入一个新的配置文件，而不是修改旧的配置文件？这是因为「fastcgi_param」指令是数组型的，和普通指令相同的是：内层替换外层；和普通指令不同的是：当在同级多次使用的时候，是新增而不是替换。换句话说，如果在同级定义两次「SCRIPT_FILENAME」，那么它们都会被发送到后端，这可能会导致一些潜在的问题，为了避免此类情况，便引入了一个新的配置文件。
- 还需要考虑一个安全问题：在PHP开启「cgi.fix_pathinfo」的情况下，PHP可能会把错误的文件类型当作PHP文件来解析。如果Nginx和PHP安装在同一台服务器上的话，那么最简单的解决方法是用「try_files」指令做一次过滤
- 初学者往往会认为「if」指令是内核级的指令，但是实际上它是rewrite模块的一部分，加上Nginx配置实际上是声明式的，而非过程式的，所以当其和非rewrite模块的指令混用时，结果可能会非你所愿

``` php
server {
    listen 80;
    server_name foo.com;

    root /path;

    location / {
    
        # 这一行应该挪出去
        index index.html index.htm index.php;

        # 这里应该用 try_files 改写
        if (!-e $request_filename) {
            rewrite . /index.php last;
        }
    }

    location ~ \.php$ {
    
        # 这一整块参考上面说的优化
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /path$fastcgi_script_name;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
    }
}
```

# 修改后的样子

``` php
server {
    listen 80;
    server_name foo.com;

    root /path;
    index index.html index.htm index.php;

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        try_files $uri =404;

        include fastcgi.conf;
        fastcgi_pass 127.0.0.1:9000;
    }
}
```

# nginx配置笔记
### location
- = 表示精确匹配。只有请求的url路径与后面的字符串完全相等时，才会命中。
- ~ 表示该规则是使用正则定义的，区分大小写。
- ~* 表示该规则是使用正则定义的，不区分大小写。
- ^~ 表示如果该符号后面的字符是最佳匹配，采用该规则，不再进行后续的查找(不是一个正则表达式匹配)。
> 先精确匹配，没有则查找带有 ^~的前缀匹配，没有则进行正则匹配，最后才返回前缀匹配的结果


### try_files

``` php
语法：try_files file ... uri 或 try_files file ... = code
作用域：server location

说明：是按顺序检查文件是否存在，返回第一个找到的文件或文件夹(结尾加斜线表示为文件夹)，如果所有的文件或文件夹都找不到，会进行一个内部重定向到最后一个参数。
```

- 检测文件$document_root/4.html和$document_root/5.html,如果存在正常显示,不存在就返回404

``` php
try_files /4.html /5.html = 404;
```

- 当用户请求 http://localhost/example 时，这里的 $uri 就是 /example。 try_files 会到硬盘里尝试找这个文件。
- 如果存在名为 /$root/example（其中 $root 是项目代码安装目录）的文件，就直接把这个文件的内容发送给用户。
- 目录中没有叫 example 的文件。然后就看 $uri/，增加了一个 /，也就是看有没有名为 /$root/example/ 的目录。
- 又找不到，就会 fall back 到 try_files 的最后一个选项 /index.php，发起一个内部 “子请求”，也就是相当于 nginx 发起一个 HTTP 请求到 http://localhost/index.php。

``` php
try_files $uri $uri/ /index.php?$query_string;
```

### root

``` php
location /dir/ 
root root_path ->  http://host/dir/file.txt  -> root_path/dir/file.txt
```

### alise

``` php
location /dir
alias alias_path ->  http://host/dir/file.txt  -> alias_path/file.txt

location /dir/ 
alias alias_path/ ->  http://host/dir/file.txt  -> alias_path/file.txt

```

> 通常最佳实际是配置一个项目的根root，其他的文件夹则使用alias，毕竟alias更加灵活。

### location规则案例

#### 「=」 修饰符：要求路径完全匹配

``` php
server {
    server_name website.com;
    location = /abcd {
    […]
    }
}
```

- http://website.com/abcd匹配
- http://website.com/ABCD可能会匹配 ，也可以不匹配，取决于操作系统的文件系统是否大小写敏感（case-sensitive）。ps: Mac 默认是大小写不敏感的，git 使用会有大坑。
- http://website.com/abcd?param1&param2匹配，忽略 querystring
- http://website.com/abcd/不匹配，带有结尾的/
- http://website.com/abcde不匹配

#### 「~」修饰符：区分大小写的正则匹配

``` php
server {
    server_name website.com;
    location ~ ^/abcd$ {
    […]
    }
}
```

> ^/abcd$这个正则表达式表示字符串必须以/开始，以$结束，中间必须是abcd

- http://website.com/abcd匹配（完全匹配）
- http://website.com/ABCD不匹配，大小写敏感
- http://website.com/abcd?param1&param2匹配
- http://website.com/abcd/不匹配，不能匹配正则表达式
- http://website.com/abcde不匹配，不能匹配正则表达式

#### 「~*」不区分大小写的正则匹配

``` php
server {
    server_name website.com;
    location ~* ^/abcd$ {
    […]
    }
}
```

- http://website.com/abcd匹配 (完全匹配)
- http://website.com/ABCD匹配 (大小写不敏感)
- http://website.com/abcd?param1&param2匹配
- http://website.com/abcd/ 不匹配，不能匹配正则表达式
- http://website.com/abcde 不匹配，不能匹配正则表达式

#### 「^~」修饰符
- 前缀匹配 如果该 location 是最佳的匹配，那么对于匹配这个 location 的字符串， 该修饰符不再进行正则表达式检测。
- 注意，这不是一个正则表达式匹配，它的目的是优先于正则表达式的匹配

### 前后端分离项目使用同一个域名的nginx配置

``` php
server {
    listen 80;
    server_name www.web.com;
    root /www/framework/public;

    # 匹配所有请求
    location / {

        # 访问前端
        root /www/web/dist;
        index index.html index.htm;
        
        # 如果访问不到则继续匹配后端
        try_files $uri $uri/ @fallback;
    }
    
    location @fallback {

        # 后端项目入口
        root /www/framework/public;

        # 匹配后端文件
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        include fastcgi.conf;
        fastcgi_pass php:9000;
    }
}
```