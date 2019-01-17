---
title: kotlin + spring boot 初体验
date: 2018-02-03
categories: java
tag: java kotlin
---

- 早就知道 kotlin 这个框架，出自 JetBrains 应该不会太差，他们家的编辑器很🐂
- 今天搭了一个 kotlin + spring boot 开发环境，写了几个小demo
- 对比了原生 Java ，确实代码写起来很带劲，越来越喜欢 Kotlin 了
- 如果以后有新项目我一定要用一次这个架构来玩一把，内置的data类太好用了

``` php
package com.example.demo

import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class Test {

    // 数据类
    data class User(val name: String, val age: Int)

    // Hello World
    @RequestMapping("/demo1")
    fun hello(): String {
        val res = "Hello World!";
        return res;
    }

    // data数据类
    @RequestMapping("/demo2")
    fun user(): Any {
        val user = User("Tommy Dai", 31);
        return user;
    }

    // 传参
    @RequestMapping("/demo3")
    fun params(name: String, age: Int): User {
        val user = User(name, age);
        return user;
    }

    // 流程控制
    @RequestMapping("/demo4")
    fun where(name: String, age: Int): User {
        if (age in 1..150) {
            val user = User(name, age);
            return user;
        } else {
            val user = User("这岁数超越了正常人类", age);
            return user;
        }
    }

    // 循环
    @RequestMapping("/demo5")
    fun foreach(name: String, age: Int): String {
        val user = User(name, age);
        var str = "";
        for (item in user.name) {
            str += item + "-";
        }
        return str;
    }

    // 泛型
    @RequestMapping("/demo6")
    fun tt(name: String, price: Int): Any {
        data class Goods<T, E>(val name: T, val price: E)
        val goods = Goods(name, price);
        return goods;
    }


}

```

# 如果以上代码用原生java实现

```php
package com.example.demo;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Test1 {
    // 数据类
    class User{
        private String name;
        private Integer age;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public Integer getAge() {
            return age;
        }

        public void setAge(Integer age) {
            this.age = age;
        }
    }

    // Hello World
    @RequestMapping("/test1")
    public String hello() {
        String res = "Hello World!";
        return res;
    }

    // data数据类
    @RequestMapping("/test2")
    public User user() {
        User user = new User();
        user.setName("Tommy Dai");
        user.setAge(31);
        return user;
    }

    // 传参
    @RequestMapping("/test3")
    public User params(String name, Integer age) {
        User user = new User();
        user.setName(name);
        user.setAge(age);
        return user;
    }

    // 流程控制
    @RequestMapping("/test4")
    public User where(String name, Integer age) {
        if (0 >= age || 150 < age) {
            User user = new User();
            user.setName(name);
            user.setAge(age);
            return user;
        } else {
            User user = new User();
            user.setName("这岁数超越了正常人类");
            user.setAge(age);
            return user;
        }
    }

    // 循环
    @RequestMapping("/test5")
    public String foreach(String name, Integer age) {
        User user = new User();
        user.setName(name);
        user.setAge(age);
        String names = user.getName();
        String str = "";
        for (int i = 0; i < names.length(); i++) {
            str += names.charAt(i) + "-";
        }
        return str;
    }

    // 泛型
    @RequestMapping("/test6")
    public Object tt(String name, Integer price) {
        class Goods<T, E>{
            public T getName() {
                return name;
            }

            public void setName(T name) {
                this.name = name;
            }

            public E getPrice() {
                return price;
            }

            public void setPrice(E price) {
                this.price = price;
            }

            private T name;
            private E price;
        }
        Goods goods = new Goods();
        goods.setName(name);
        goods.setPrice(price);
        return goods;
    }


}

```

# 显而易见，相同功能Kotlin的代码几乎比Java少一半
> var 和 val 定义变量和常量非常方便
> 你可以避免 NullPointerException
> 学习成本低，Kotlin已正式成为Android官方支持开发语言，有取代java之势