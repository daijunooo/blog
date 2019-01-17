---
title: php系统函数未必都是效率最优
date: 2017-09-23
categories: fun
tag: php fun
---

# 10万条数据去重测试

> php版本5.6.27
> 使用系统函数 array_unique() 测试
> 运行效率和自己写的相差甚远

``` php
$time1 = microtime(true);

for ($i = 0; $i < 100000; $i++) {
    $arr[] = rand(0, 100000);
}

$time2 = microtime(true);
echo $time2 - $time1;      //运行结果:0.23166012763977
echo ' 假数据生成时间<br>';

foreach ($arr as $val) {
    $array[$val] = $val;
}

$time3 = microtime(true);
echo $time3 - $time2;     //运行结果:0.020256042480469
echo ' 键值对调去重时间<br>';

$arr1 = array_unique($arr);

$time4 = microtime(true);
echo $time4 - $time3;    //运行结果:0.9081289768219
echo ' 系统函数去重时间<br>';
```

- 以后不要以为系统提供的就是效率最好的了
- 另外测试中还发现 array_unique() 执行时会占用很大内存
- 并且当数据量在100万条时直接报错，超出内存限制了，需要改配置信息