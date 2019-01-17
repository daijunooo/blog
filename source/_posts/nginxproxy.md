---
title: nginx反向代理解决公众号文章图片访问限制
date: 2018-04-24
categories: fun
tag: nginx
---

### nginx反向代理解决微信图片不能访问
- 微信公众号发布的文章里面的图片是不能直接src使用的，如果想要使用可以有多种方案，百度可以搜出一大堆。
- nginx反向代理这种方案稍微麻烦一点，但是好处是大部分防盗链图片重新拼装一个地址就能突破限制了。

``` php
server {
    listen       80;
    server_name  www.pic.com;

    location /proxy/ {
        set $hostx "";
        set $addrs "";
        if ( $uri ~ "^/proxy/([^/]+)/(.+)$") {
            set $hostx $1;
            set $addrs $2;
        }
        proxy_redirect     off;
        proxy_set_header   Referer    "";
        proxy_pass http://$hostx/$addrs;
    }
}

http {
	resolver 8.8.8.8 ipv6=off;
}


访问下面的图片
http://img01.sogoucdn.com/app/a/100520090/oIWsFt035HAcDpdyxSsWNcUunQ58

改为此链接就可以访问了
http://www.pic.com/proxy/img01.sogoucdn.com/app/a/100520090/oIWsFt035HAcDpdyxSsWNcUunQ58

任意防盗链的图片访问
http://www.pic.com/proxy/<图片地址（不包含http://）>

```
