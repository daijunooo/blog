---
title: java项目不发版紧急修复线上bug
date: 2026-09-22
tag: java
---

# 使用 arthas 替换字节码

``` php
# step 1 查看 java pid 号
top 查看 java 的 pid 进程号，例如：1

# step 2 启动 arthas
as.sh 1

# step 3 本地修复代码后编译，把编译好的类的class文件上传到线上服务器例如：demo.class
retransform demo.class

# step 4 根据上一步命令结果，如果替换成功，测试bug是否修复。如果替换错了可以倒退
retransform --deleteAll

```

https://arthas.aliyun.com/doc/
