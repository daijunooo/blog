---
title: OPcache之一次愉快的php性能优化实践
date: 2018-11-12
categories: php
tag: php
---

# 项目优化的时机
- 公司的项目日趋稳定了，新需求也越来越少，这时候有大把时间研究新东西和优化项目。前期为了赶进度写了一些流水账式的代码，现在都可以花时间重构了。我用了一两天时间优化了调用频繁的api，当大部分优化都做的差不多的时候，接口效率确实大有提升。开始考虑怎么样再继续优化。这时我接触了Golang，框架都搭好了，准备用Go语言写rpc服务，由于目前这个项目的用户量和数据量还不是很多，用Go好像看不出提升的效果，在做了一些测试后也证明了我的想法。后来想到了OPcache，就用到了项目中，接口效率又提升了不少。接口响应时间降到了100ms以下,相比之前提升了30%左右。在并发的情况下大部分接口的响应时间都在200ms以下。

# 小故事

> 小明想和一个老外吹牛，他必须先找一个翻译，因为小明只念过小学。于是乎他找到了大黑给他做翻译，这样他高兴的把一个个牛都吹上了天。虽然沟通起来慢了一点，但是好歹不用学英文了。突然有一天小明捡到一个神灯，神灯说：“别给我说你有什么愿望，老子天天帮别人完成愿望，谁管过我有什么愿望！”。刚说完就跑回灯里去了。小明是一脸懵逼，他抬头看见一个老外，脱口而出“What the fuck!”,顿时他察觉到了什么，好像他不需要翻译了，神灯给他开了挂。一口流利的英语......,从此吹一只牛加上翻译的时间需要1分钟，缩短到不用翻译10秒搞定。提高了吹牛逼的效率。

- 带着以上小故事就可以理解下面的原理了。
- OPcache:  通过将 PHP 脚本预编译的字节码存储到共享内存中来提升 PHP 的性能， 存储预编译字节码的好处就是 省去了每次加载和解析 PHP 脚本的开销。
- 这个小故事不是很恰当，但是可以帮我们理解原理，小明就是我们写的php代码，神灯给他开的挂叫OPcache，而听他吹牛逼的老外是服务器主机。

# 开启步骤

> PHP5.5.0以后版本自带Opcache加速器，但默认情况下木有启用。所以编译的使用我们想要启用该PHP加速器就应该添加参数 ： –enable-opcache 来制定。

- 查找php自带包的位置，使用下面的命令
``` php
[root]# find / -name opcache
/usr/local/php-5.6/extcode/opcache
```

- 查找phpize的位置
``` php
[root]# find / -name phpize
/usr/local/php-5.6/bin/phpize
/usr/local/php-generic-5.3/bin/phpize
```

- 切换到opcache包的目录
``` php
[root]# cd /usr/local/php-5.6/extcode/opcache
```

- 然后在包的目录，执行phpize
``` php
[root opcache]# /usr/local/php-5.6/bin/phpize
Configuring for:
PHP Api Version:         20090626
Zend Module Api No:      20090626
Zend Extension Api No:   220090626
```

- 不要切换目录，继续在当前目录下执行下面的configure
``` php
./configure --with-php-config=/usr/local/php-5.6/bin/php-config
```

- 还是在这个目录，继续编译文件

``` php
make && make install


Build complete.
Don't forget to run 'make test'.

Installing shared extensions:     /usr/local/php-5.6/lib/php/extensions/no-debug-non-zts-20131226/
```

- 最后它会告诉你opcache.so已经编译成功，就放在/usr/local/php-5.6/lib/php/extensions/no-debug-non-zts-20131226/这个目录里。
- 用vi打开php.ini，编写opcache的配置参数。如果你不知道你的php.ini在哪里，可以用phpinfo.php来查看

``` php
vi /home/wwwroot/etc/php.ini
```

- 将下面的代码放置在php.ini的最后面，保存后退出
``` php
[opcache]
zend_extension="/usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/opcache.so"
opcache.enable=1
opcache.revalidate_freq=0
opcache.validate_timestamps=0
opcache.max_accelerated_files=7963
opcache.memory_consumption=192
opcache.interned_strings_buffer=16
opcache.fast_shutdown=1
```

- 重启apache

``` php
service httpd restart
```

- 成功重启后通过查看phpinfo()可以看到OPcache相关信息。
- 此时可以借助调试工具查看接口响应时间，是不是比之前有一定提升呢！
- 在测试中，我的接口效率有明显提升，小程序端明显流畅了很多。


# 注意事项
- 开启OPcache后，服务器上的代码更新后不是即刻生效的，这对于我们版本迭代是不方便的。
- 为了解决上面的不方便我找到了一个好的解决方案，写一个专门的接口，调用一次 opcache_reset(),这样OPcache就会被重置，新代码就会生效。

``` php
public function refreshCode()
{
    $res = opcache_reset();
    return json(['result' => $res]);
}
```

- [OPcache的相关配置这篇文章说的很好很详细](https://segmentfault.com/a/1190000005844450)