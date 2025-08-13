---
title: 代码管理的小技巧
date: 2025-04-27
categories: fun
tag: 最佳实践
---


[![pETDehj.png](https://s21.ax1x.com/2025/04/27/pETDehj.png)](https://imgse.com/i/pETDehj)

[![pETD3HU.png](https://s21.ax1x.com/2025/04/27/pETD3HU.png)](https://imgse.com/i/pETD3HU)

[![pEHIo3q.png](https://s21.ax1x.com/2025/05/01/pEHIo3q.png)](https://imgse.com/i/pEHIo3q)

``` php
#!/bin/bash

path=$(pwd);
basename=$(basename "$path");

# 当前迭代的分支名称
dev="feature_v5.7.9"; # 维信权益

# 获取当前默认分支
function master() {
  git remote show origin | grep "HEAD branch" | awk '{print $NF}'
}
function branch() {
  [[ $(pwd) =~ billbear-third-api && $dev =~ feature_v4.5.1 ]] && echo "feature_v4.5.1_lz" || echo "$dev"
}

# push
if [ "push" = $1 ]; then
#  git checkout $(branch) && git pull;
  git checkout dev && git pull --rebase && git merge $(branch) --message "merge $(branch) into dev" && git push;
  git checkout test && git pull --rebase && git merge $(branch) --message "merge $(branch) into test" && git push;
  git checkout $(branch);
fi

# 快捷操作
if [ "biubiu" = $1 ]; then
#  git stash && git checkout $(master) && git pull --rebase && git checkout -b $(branch) && git stash pop;
  git checkout $(master) && git pull --rebase && git checkout -b $(branch);
#  git checkout $(master) && git pull --rebase > /dev/null && git log $(master)..$(branch); # 检查发版
fi

# 切分支
if [ "dev" = $1 ]; then
  git checkout dev && git pull --rebase;
fi
if [ "test" = $1 ]; then
  git checkout test && git pull --rebase;
fi
if [ "master" = $1 ]; then
  git checkout $(master) && git pull --rebase;
fi
if [ "feature" = $1 ]; then
  git checkout $(branch) && git pull --rebase;
fi

# 批量
if [ "batch" = $1 ]; then
  for dir in */; do
    cd "$path/$dir" || exit;
#    /Applications/IntelliJ\ IDEA.app/Contents/plugins/maven/lib/maven3/bin/mvn clean
#    find ./ -type f -name "*.iml" -delete;
#    git checkout $(master) &> /dev/null && git pull --rebase &> /dev/null;

# 输出本期迭代所有改动，并比较与主分支的差异提交个数
     git checkout $(branch) &> /dev/null && echo $(basename "$dir") && git rev-list --count $(master)..$(branch);
#     git checkout $(branch) &> /dev/null;
  done
fi

# deploy
if [ "deploy" = $1 ]; then
cd /Users/daijun/IdeaProjects/vip/billbear-third-api/billbear-weixin-api


cd /Users/daijun/IdeaProjects/vip/billbear-interests/billbear-interests-facade-stub


cd /Users/daijun/IdeaProjects/vip/billbear-paycenter/billbear-paycenter-facade-stub


cd /Users/daijun/IdeaProjects/vip/billbear-common/common-spring-boot-starter


cd /Users/daijun/IdeaProjects/vip/billbear-message-notify/billbear-message-notify-facade-stub


cd /Users/daijun/IdeaProjects/vip/billbear-after-sales/billbear-after-sales-facade

fi



```

# 使用方法
- 对于微服务项目，直接在项目任意目录或者文件上，右击，按图一的方式选择操作，即可完成代码的管理
- 其他项目可以通过软链接的方式，将这个shell文件链接到项目下，通过定义多个branch方式，方便知道当前在开发哪些迭代
