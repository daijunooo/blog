---
title: Java 多线程笔记
date: 2020-02-29
categories: java
tag: java
---

# 什么是线程?
- 引用马士兵老师一句话：线程是一个程序里面不同的执行路径
- 比喻：一个厕所里面的不同坑位或者一个工厂里面的多个生产车间；
- 维基百科：线程（英语：thread）是操作系统能够进行运算调度的最小单位。大部分情况下，它被包含在进程之中，是进程中的实际运作单位。

# java中如何实现多线程
1. 重写Thread的run方法

``` php
Thread thread1 = new Thread() {
    @Override
    public void run() {
        System.out.println("新线程1执行了");
    }
};
thread1.start();
```

2. 实现Runnable接口的run方法

``` php
Thread thread2 = new Thread(new Runnable() {
    @Override
    public void run() {
        System.out.println("新线程2执行了");
    }
});
thread2.start();

//JDK1.8开始支持lambda语法，以上代码可以简写成下面这样
Thread thread2 = new Thread(() -> {
    System.out.println("新线程2执行了");
});
thread2.start();

```

# 线程的状态
1. new：初始状态 - 线程被new出来时处于此种状态
2. Runnable：就绪状态 - 当一个线程的start方法被调用或正在运行的线程CPU时间片耗尽或处于阻塞状态的线程满足了运行条件时处于此种状态。就绪状态的线程处于CPU调度队列中等待获得CPU时间片执行。
3. Running：运行状态 - 处于就绪状态的线程获取到CPU时间片，正在执行。
4. Blocked：阻塞状态 - 当线程要执行的必要条件无法满足时处于此种状态，如等待其他线程释放锁、等待IO等。当这些条件得到满足后线程变为就绪状态。
5. Dead：死亡状态 - 当线程run方法执行完或者遇到异常退出时线程死亡，线程的生命周期就此终止。
![image](http://daijunooo-img.test.upcdn.net/blog/thread.jpg)

# 常用方法
- join：当在一个线程A中调用另一个线程B的join方法时，线程A会等待线程B执行完再进行执行。
- yield：发送一个通知给调度器表示当前线程愿意让出CPU时间片给其他线程先执行，但是这种让步策略并不能得到保障，因为调度器可以选择忽视这个通知，这取决于当前下同的线程调度策略。
- sleep：使当前线程休眠指定时间，处于休眠的线程并不会放弃已经持有锁，放不放弃锁是sleep方法与wait方法的最大区别。
- setPriority：设置线程的优先级，传入一个1到10之间的整数，数值越大表示优先级越高，在一个母线程中创建一个子线程则子线程的优先级默认与母线程相同。


