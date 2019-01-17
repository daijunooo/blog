---
title: java 反射之动态调用
date: 2017-08-12
categories: java
tag: java
---

> 在Java项目中根据参数不同动态调用不同的方法，如果参数个数或类型不同可以使用方法重载实现，可是偏偏我现在参数个数和类型是不会变的，仅仅是
参数的值变化，通过if判断是可以的，但是当后续业务足够复杂时，需要维护流程控制这部分代码。这个需求在php中是很容易实现的，在Java中我能想到的
只有反射了。

# php中动态调用方法
```php
class Boy {

    public function say() {
        echo "走吃鸡去！";
    }

    public function run() {
        echo "跑到网吧！";
    }
}

$func = "run";

(new Boy)->{$func}(); // 执行结果：跑到网吧！

$func = "say";

(new Boy)->{$func}(); // 执行结果：走吃鸡去！

```
# java中动态调用

```java
public class Boy {

    public void say() {
        System.out.println("走吃鸡去！");
    }

    public void run() {
        System.out.println("跑到网吧！");
    }

}

String func = "say";

Method method = Boy.class.getMethod(func, null);
Object object = Boy.class.newInstance();
method.invoke(object, null);  // 执行结果：走吃鸡去！

String func = "run";

Method method = Boy.class.getMethod(func, null);
Object object = Boy.class.newInstance();
method.invoke(object, null);  // 执行结果：跑到网吧！

```

# 动态调用有何意义？🤔️

> 完全可以使用if判断来动态调用
> 但是当业务逻辑足够复杂或多的时候，需要维护流程控制这部分代码
> 用反射就解耦的这部分流程控制的代码，可以说反射是java框架的核心
> PHP中也有反射，一般框架层面会用到，日常开发几乎没见到过。