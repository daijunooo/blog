---
title: Java是如何实现AOP的
date: 2019-08-09
categories: java
tag: java
---

``` php
/**
 * 人类的抽象
 */
public interface Person {
    void say();
}
```


``` php
/**
 * 男人(实现Person)
 */
public class Man implements Person {
    @Override
    public void say() {
        System.out.println("Man: Hello everyone!");
    }
}
```


``` php
/**
 * 代理（必须实现 InvocationHandler 接口）
 */
public class ProxyPerson implements InvocationHandler {

    private Object obj;

    ProxyPerson(Object obj) {
        this.obj = obj;
    }

    Object getInstance() {
        return Proxy.newProxyInstance(obj.getClass().getClassLoader(), obj.getClass().getInterfaces(), this);
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("调用前：" + method);
        method.invoke(obj, args);
        System.out.println("调用后：" + method);
        return null;
    }

}
```


``` php
public class DemoApplication {

    public static void main(String[] args) {
        Person person = (Person) new ProxyPerson(new Man()).getInstance();
        
        // 调用say会自动调用到代理类的invoke方法
        person.say();
    }

}
```

- Proxy.newProxyInstance 这个地方返回的是 com.sun.proxy.$Proxy0 代理类
- 调用 $Proxy0 的 say 方法会调用到 $Proxy0 父类 ProxyPerson 的 InvocationHandler.invoke() 方法
- Proxy.newProxyInstance 是整个过程的关键，它会动态的生成 com.sun.proxy.$Proxy0 代理类