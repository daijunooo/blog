---
title: Java 基础学习笔记
date: 2019-08-12
categories: java
tag: java
---

### 基本数据类型
- Java 的两大数据类型: 内置数据类型，引用数据类型

| 类型 | byte | short | int | long | float | double | boolen | char |
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
| 内存占用 | 1字节 | 2字节 | 4字节 | 8字节 | 4字节 | 8字节 | 1字节 | 2字节 |
| 默认值 | 0 | 0 | 0 | 0L | 0f | 0.0d | false | 'u0000' |

> 所有引用类型的默认值都是 null,

### 变量类型
``` php
public class Var {
    
    // 类变量：独立于方法之外的变量，用 static 修饰
    static int a = 1;
    
    // 实例变量：独立于方法之外的变量，不过没有 static 修饰
    private int b = 1;
    
    public void c() {
        
        // 局部变量：类的方法中的变量
        int d = 1;
    }
}
```
- 在 Java 中使用 final 关键字来修饰常量，声明方式和变量类似,如：final String LOVE = 'java'
- 类变量被声明为public static final类型时，类变量名称一般建议使用大写字母

### 修饰符
1. 访问控制修饰符

| 修饰符 | public | protected | default | private |
|:----:|:----:|:----:|:----:|:----:|
| 权限 | 所有 | 本类,子类,同包 | 本类及同包名下字类 | 本类 |

> 子类与基类不在同一包中：那么在子类中，子类实例可以访问其从基类继承而来的 protected 方法，而不能访问基类实例的protected方法。

2. 非访问修饰符

- static, final, abstract, synchronized, transient, volatile
- synchronized: 方法同一时间只能被一个线程访问
- volatile: volatile 修饰的成员变量在每次被线程访问时，都强制从共享内存中重新读取该成员变量的值。而且，当成员变量发生变化时，会强制线程将变化值回写到共享内存。这样在任何时刻，两个不同的线程总是看到某个成员变量的同一个值。

### 数组
``` php
// 数组的声明（Type[] var; 推荐第一种的声明方式，）
int[] a;  
int b[]; //为了C++程序员快速理解而设计

// 创建数组
String[] a = {"天天", "向上"};

int size = 2;
String[] b = new String[size];
b[0] = "好好";
b[1] = "学习";
```
> java.util.Arrays 类能方便地操作数组，它提供的所有方法都是静态的(fill,sort,equals,binarySearch)。

### 包装类
- 所有的包装类（Integer、Long、Byte、Double、Float、Short）都是抽象类 Number 的子类
- Character 类用于对单个字符进行操作。
- 在 Java 中字符串属于对象，Java 提供了 String 类来创建和操作字符串。
- 当对字符串进行修改的时候，需要使用 StringBuffer 和 StringBuilder（线程不安全） 类。

### 日期时间
- java.util 包提供了 Date 类来封装当前的日期和时间。 Date 类提供两个构造函数来实例化 Date 对象。
- SimpleDateFormat 是一个以语言环境敏感的方式来格式化和分析日期的类。SimpleDateFormat 允许你选择任何用户自定义日期时间格式来运行

### Java 流(Stream)、文件(File)和IO
- Java.io 包几乎包含了所有操作输入、输出需要的类

``` php
// 从控制台读取字符串
BufferedReader i = new BufferedReader(new InputStreamReader(System.in));
String c;
do {
    c = i.readLine();
    System.out.println("输入：" + c);
} while (!c.equals("end"));
```

### 多线程编程中的三个核心概念
- 原子性: 即一个操作（有可能包含有多个子操作）要么全部执行（生效），要么全部都不执行（都不生效）。实现手段（锁和同步synchronized、lock）
- 可见性：当多个线程并发访问共享变量时，一个线程对共享变量的修改，其它线程能够立即看到。实现手段（volatile）
- 顺序性：JVM真正在执行代码时，并不保证它们一定完全按照顺序执行，处理器为了提高程序整体的执行效率，可能会对代码进行优化，其中的一项优化方式就是调整代码顺序，按照更高效的顺序执行代码。
> 相关类：Runnable、Thread、ThreadLocal、java.util.concurrent ...
