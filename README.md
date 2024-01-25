# 快速使用

``` php
安装依赖：
docker run --rm -it --init -v "$(pwd):/www" node:7.2.0-alpine sh -c "cd /www && npm install"

启动服务：
docker run --rm -it --init -v "$(pwd):/www" -p 4000:4000 node:7.2.0-alpine sh -c "cd /www && ./node_modules/.bin/hexo serve"

清空缓存：
docker run --rm -it --init -v "$(pwd):/www" node:7.2.0-alpine sh -c "cd /www && ./node_modules/.bin/hexo clean"

生成文章：
docker run --rm -it --init -v "$(pwd):/www" node:7.2.0-alpine sh -c "cd /www && ./node_modules/.bin/hexo generate"

```
