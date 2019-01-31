---
title: php反编译微信小程序浅析
date: 2019-01-31
categories: fun
tag: fun
---

### 此文由来
- 百度搜索 “反编译微信小程序” 能得到一大堆教程，github有一个是用php实现的反编译程序，以前没接触过此类开发，就clone下来分析了一下源码。
- 源码地址: [unpack-wxapkg](https://github.com/Clarence-pan/unpack-wxapkg)

### 原理概述
- 通过一些手段可以获取到小程序的源码包wxapkg文件，用编辑器sublime打开这个文件里面是一大堆16进制。通过php代码读取这个文件，根据一定的规则去把这个打包后的文件还原成项目目录和代码。
- wxapkg文件是明文存储的，所以为反编译提供了可能和便利。用在线16进制转字符串工具转换后可以看到部分文件信息。
- 一般的二进制文件里储存了大量的offset和size的数据作为数据段的索引。最关键的所谓offset，就是目标数据在文件中的实际位置了，一般是ulong的数据，实际就是一个指针。一般读取文件时会先找到一个offset，然后file.seek(offset)到对应的位置然后接着读区。对于较为复杂的文件格式，offset飞来飞去非常频繁。同样，大部分储存了offset的地方也储存了size的，用于校验数据避免指针越界嘛。因此，一旦我们可以确认一个文件中某一段数据段，就可以通过它的位置（offset）和大小（size）的实际数据进行搜索，逆向找到指向它的数据位置，并且继续逆向直到解析完整的文件。

### 预备知识

#### 字节序
- 字节序，简单来说，就是指超过一个字节的数据类型在内存中存储的顺序
- 通俗理解古人写字是自上而下从右往左，我们现代人是从左往右一行一行往下写。计算机存数据时也分顺序😂
- 计算机存数据时也分为两种：大端序（Big endian）、小端序（Little endian）

``` php
<?php
// 大端序存储十进制数4660，转成十六进制后0x1234
echo bin2hex(pack('n', 0x1234));
echo '<br>';
// 小端序存储十进制数4660
echo bin2hex(pack('v', 0x1234));
```

- 运行后输出

``` php
1234
3412
```
- 1234这种符合人类阅读的方式称之为大端序，但是计算机处理起来方便的是小端序3412，因此计算机内部一般都使用小端序又叫主机序，人类设计的协议等一般都使用大端序。
- 因此人类和计算机之间就需要转换

### 原理解析:源码包wxapkg文件部分内容(前10行)

``` txt
be00 0000 0000 001f 1200 29cc efed 0000
0095 0000 0010 2f61 7070 2d63 6f6e 6669
672e 6a73 6f6e 0000 1f20 0000 c9c2 0000
000f 2f61 7070 2d73 6572 7669 6365 2e6a
7300 00e8 e200 1436 9200 0000 1f2f 636f
6d70 6f6e 656e 742f 4261 636b 4274 6e2f
4261 636b 4274 6e2e 6874 6d6c 0015 1f74
0000 0147 0000 001b 2f63 6f6d 706f 6e65
6e74 2f43 5f62 7579 2f43 5f62 7579 2e68
746d 6c00 1520 bb00 0001 3f00 0000 212f
```
> 乍看这什么玩意，有人分析出了这个文件的结构,见下表

| 段       | 名称     |  类型   |   备注   |
| -------- |-------- |-------- |-------- |
| header | firstMark | Ushort | 一定是190 |
| header | info | Ulong | 作用未知，总是0 |
| header | indexInfoLength | Ulong | 索引段长度，用于校验 |
| header | bodyInfoLength | Ulong | 数据段长度，用于校验 |
| header | lastMark | Ushort | 一定是237 |
| header | fileCount | Ulong | 文件数目 |
| index | nameLength | Ulong | 文件名长度 |
| index | name | Char* | 长度为nameLength |
| index | offset | Ulong | 文件在数据段位置 |
| index | size | Ulong | 文件大小 |
| data |  |  | 文件数据 |

- 这个表格最关键的部分就是 header 和 index 段，这两段就决定了整个数据段是什么结构。
- 用这个表格给出的规则就可以解出源码包wxapkg文件的内容。

> unpack 函数用于解包，参数1就是刚刚提过的字节序相关内容，参数2是字符串
> 上面表格 header 第一行的类型是 Ushort ，对应 unpack 的参数就是 C
> Ushort是1个字节，所以从源码包wxapkg文件中取前1个字节就是 be ，由于 unpack 参数2需要传字符串，转换后 "\xbe"

``` php
<?php
print_r(unpack('C', "\xbe"));
```

- 运行后打印

``` php
Array
(
    [1] => 190
)
```
- 结果正好是190，符合上表的第一行的说明

> 如果我现在想获取文件数目，结合表格给出的信息
> fileCount之前依次有lastMark（1字节）、bodyInfoLength（4字节）、indexInfoLength（4字节）、info（4字节）、firstMark（1字节）
> 应从第15个字节开始，fileCount（Ulong）取4个字节，就是0000 0095


``` php
<?php
print_r(unpack('N', "\x00\x00\x00\x95"));

结果：
Array
(
    [1] => 149
)
```

> 获取第一个文件的文件名长度

``` php
<?php
print_r(unpack('N', "\x00\x00\x00\x10"));

结果：
Array
(
    [1] => 16
)
```

> 利用上面获取的文件名长度获取第一个文件的文件名
> 取16字节文件名数据 2f61 7070 2d63 6f6e 6669 672e 6a73 6f6e

``` php
<?php
print_r(unpack('a*', "\x2f\x61\x70\x70\x2d\x63\x6f\x6e\x66\x69\x67\x2e\x6a\x73\x6f\x6e"));

结果：
Array
(
    [1] => /app-config.json
)
```
> 其他信息也可以继续通过这种方式一一解析出来
> 根据 header 和 index 信息可以完整还原出源码包wxapkg文件的项目目录和代码

### 总结
- 解包的核心就是php提供的unpack函数，与之对应的还有个pack函数，用于打包操作
- 解包的关键点就是上边网友分析的文件结构和unpack的参数1的选取