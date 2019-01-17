---
title: php多线程开发
date: 2018-03-13
categories: php
tag: php 高性能php开发
---

#### php多线程简介

- pthreads 是一组允许用户在 PHP 中使用多线程技术的面向对象的 API。 它提供了创建多线程应用所需的全套工具。 通过使用 Thread， Worker 以及 Threaded 对象，PHP 应用可以创建、读取、写入以及执行多线程应用，并可以在多个线程之间进行同步控制。
> 多线程的使用安全请自行查阅php官方文档，用在项目中请谨慎使用。

#### 1.安装pthreads扩展

- 此步骤不做说明，我相信大部分人都能自行解决，实在不行百度，安装过程略...


``` php
class AsyncOperation extends Thread
{
    public function __construct($arg)
    {
        $this->arg = $arg;
    }

    public function run()
    {
        if ($this->arg) {
            printf("Hello %s\n", $this->arg);
        }
    }
}

$thread = new AsyncOperation("World");
if ($thread->start())
    $thread->join();

//安装好后执行此脚本 如能看到“Hello World”说明扩展已安装成功
//或者通过  phpinfo()  查看是否有pthreads扩展，有一般也安装成功了
//再或者通过命令行  php -m  查看是否有pthreads扩展也可
```

#### 2.多线程开发应用
- 一个简单的小栗子

``` php
class Cattle extends Thread
{
    public function run()
    {
        // 输出当前线程ID
        sleep(1);
        echo $this->getCurrentThreadId(), "\n";
    }
}

// 当调用 Thread 对象的 start 方法时，该对象的 run 方法将在独立线程中并行执行。
(new Cattle)->start();
(new Cattle)->start();
(new Cattle)->start();
(new Cattle)->start();

// 代码执行结果是每隔一秒才输出一次线程ID
// 这样其实是同步阻塞的，并不是并行处理，这里其实有个大坑
// PHP内核中的垃圾回收器并不适用于pthreads的这种运行方式。
// 当你有需要被运行的对象(thread,stackables)时,或者有对象
// 需要被其它上下文获取时,你需要保留好对象的引用,直到它们不再被使用
```

- 正确的打开方式是这样的

``` php
class Cattle extends Thread
{
    public function run()
    {
        // 输出当前线程ID
        sleep(1);
        echo $this->getCurrentThreadId(), "\n";
    }
}

// 开启 4 个线程
for ($i = 0; $i < 4; $i++) {
    $cattle[] = new Cattle();
}

// 当调用 Thread 对象的 start 方法时，该对象的 run 方法将在独立线程中并行执行。
foreach ($cattle as $object) {

    // 这里的 $object 就是对象的引用
    $object->start();
}

// 代码执行结果是一秒后输出 4 个线程ID
// 这才是并行处理嘛
```
- php 多线程只适用于命令行模式，以上代码在web模式下会有差异
- 多线程对于写高性能应用是很有帮助的，并行计算，并行IO等等
- 多线程还有其他一些用法和知识点，感兴趣可以自行研究一下

#### 3.多线程解决计算密集型任务性能问题
- 阿姆斯特朗数(俗称水仙花数)
- 例如：1^3 + 5^3+ 3^3 = 153 这个就是水仙花数
> 用php实现求水仙花数，分别用单线程和双线程测试


``` php
$time1 = microtime(true);

for ($i = 0; $i < 100000; $i++) {

    // 位数长度
    $numLength = 0;

    // 每个进制上的数
    $numArray = array();

    for ($w = 10; 1; $w *= 10) {
        $numArray[] = floor($i % $w / ($w / 10));
        if ($i < $w) {
            $numLength = log10($w);
            break;
        }
    }

    // 计算结果
    $countResult = 0;
    foreach ($numArray as $num) {
        $countResult += pow($num, $numLength);
    }

    // 判断是否是水仙花数
    if ($countResult == $i) {
        echo $countResult, "\n";
    }
}

$time2 = microtime(true);
echo '任务耗时：', $time2 - $time1;
```
- 用其他语言也可以试试，看看性能如何
> 下面用多线程实现一下

``` php
class Cattle extends Thread
{
    public $start;
    public $end;

    public function __construct($start, $end)
    {
        $this->start = $start;
        $this->end = $end;
    }

    public function run()
    {
        $time1 = microtime(true);

        for ($i = $this->start; $i < $this->end; $i++) {

            // 位数长度
            $numLength = 0;

            // 每个进制上的数
            $numArray = array();

            for ($w = 10; 1; $w *= 10) {
                $numArray[] = floor($i % $w / ($w / 10));
                if ($i < $w) {
                    $numLength = log10($w);
                    break;
                }
            }

            // 计算结果
            $countResult = 0;
            foreach ($numArray as $num) {
                $countResult += pow($num, $numLength);
            }

            // 判断是否是水仙花数
            if ($countResult == $i) {
                echo $countResult, "\n";
            }
        }

        $time2 = microtime(true);
        echo '任务耗时：', $time2 - $time1, "\n";
    }
}

// 开启 2 个线程
$cattle[] = new Cattle(0, 500000);
$cattle[] = new Cattle(500000, 1000000);

foreach ($cattle as $object) {
    $object->start();
}
```

- 单线程和多线程运行结果

``` php
最大数10万
单线程                              多线程
0          							0
1          							1
2          							2
3          							3
4          							4
5          							5
6          							6
7          							7
8          							8
9          							9
153         						153
370         						370
371         						371
407         						407
1634        						1634
8208        						54748
9474        						8208
54748       						9474
92727       						92727
93084       						93084
任务耗时：4.6810078620911           任务耗时：2.6842050552368 （线程1）
          						   任务耗时：2.7934041023254 （线程2）
增加一个数量级，最大数100万测试结果

0          							0
1          							1
2          							2
3          							3
4          							4
5          							5
6          							6
7          							7
8          							8
9          							9
153          						153
370          						370
371          						371
407          						407
1634          						1634
8208          						8208
9474          						9474
54748          						54748
92727          						548834
93084          						92727
548834          					93084
任务耗时：56.342707872391          	任务耗时：32.016864061356
          							任务耗时：33.077666044235
```
##### 总结
- 多线程并行处理确实对性能有提升，测试还用了4线程
- 但是并没有2线程效率好，测试电脑是公司的台式机
- cpu是G2030，主频3.0Ghz，双核。但不是双核4线程
- 原因就在此了，如果核心数多些效率提升将会更明显
- 多核测试时，由于是并行计算，所以输出的水仙花数
- 不是按大小顺序，总耗时应按所有线程中的最大耗时
- 以上测试结果是关闭所有其他程序时测试的，如果有
- 其他高cpu占用的程序在运行，测试结果会不准