---
title: composer 包依赖问题解决
date: 2021-12-17
categories: fun
tag: php
---


# 包版本栗子
- ~1.2.3 代表 1.2.3 <= 版本号 < 1.3.0
- ^1.2.3 代表 1.2.3 <= 版本号 < 2.0.0

# 查询版本依赖
> composer depends guzzlehttp/guzzle

``` php
overtrue/easy-sms   2.0.4   requires  guzzlehttp/guzzle (^6.2 || ^7.0)
overtrue/socialite  2.0.24  requires  guzzlehttp/guzzle (^5.0|^6.0|^7.0)
overtrue/wechat     4.4.3   requires  guzzlehttp/guzzle (^6.2 || ^7.0)
```

- 所以guzzlehttp/guzzle可装6.2以上版本或者7.0以上版本

# 案例

### 安装 beyondcode/laravel-websockets:2.0.0-beta.24 包
> 报依赖问题guzzlehttp/psr7必须使用 ^1.5 版本，但系统中已安装的是 ^2.1 的版本

### 查询依赖
- composer depends guzzlehttp/psr7
- 目前系统中只有 guzzlehttp/guzzle 用到了 guzzlehttp/psr7
- (^1.8.3 || ^2.1) 这两个版本都可以

``` php
guzzlehttp/guzzle  7.4.0  requires  guzzlehttp/psr7 (^1.8.3 || ^2.1)
```

### 解决依赖问题

``` php
//移除现有的guzzlehttp/psr7
composer remove guzzlehttp/psr7

//安装两个包都支持的版本
composer require guzzlehttp/psr7:1.8.3

//安装目标开发包
composer require beyondcode/laravel-websockets:2.0.0-beta.24
```

