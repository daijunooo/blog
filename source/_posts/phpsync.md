---
title: php模拟异步执行(超简单)
date: 2018-03-10
categories: php
tag: php
---

- 新用户注册后台推送一封邮件？执行某个操作完成后再执行耗时的复杂任务？想用php异步又发现各种坑？
- 我也遇到过这样的问题，今天偶然在网上发现了一种新的思路，既简单又暴力。
- 原理是强制php返回内容到浏览器，并且断开连接，执行后续操作。


``` php
echo '你看到了我，但是我仍然在干活！';
close_connect();

//模拟后台执行复杂任务
for ($i = 0; $i < 5; $i++) {
    file_put_contents(__DIR__.'/a.log', "i={$i}我仍然在干活！\r\n", FILE_APPEND);
    sleep(1);
}

//强制输出结果到浏览器并断开连接
function close_connect(){
    ignore_user_abort(true);
    set_time_limit(0);
    $size=ob_get_length();
    header("Content-Length: $size");
    header("Content-type:text/html;charset=utf-8");
    header("Connection: Close");
    ob_flush();
    flush();
}
```