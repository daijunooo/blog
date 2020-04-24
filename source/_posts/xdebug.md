---
title: 记一次 phpstudy 开启 xdebug 的坑
date: 2020-04-21
categories: fun
tag: php
---

# 开启最新版 phpstudy v8 自带 xdebug


``` php
;extension=php_xdebug

改为

extension=php_xdebug

```

> 然而怎么也无法正常使用，phpstorm 报错 Cannot accept external Xdebug connection: Cannot evaluate expression 'isset($_SERVER['PHP_IDE_CONFIG'])'

# 留意 phpinfo() 里面的信息有这么一段


``` php
XDEBUG NOT LOADED AS ZEND EXTENSION
```

# 解决过程

``` php
extension=php_xdebug

改为

;extension=php_xdebug

添加以下配置

[XDebug]
zend_extension="D:\phpstudy_pro\Extensions\php\php5.6.9nts\ext\php_xdebug.dll"
xdebug.idekey=PHPSTORM
xdebug.remote_enable=1

```

- zend_extension 必须要以这个方式配置才可以