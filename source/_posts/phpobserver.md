---
title: php的SPL之快速实现Observer (观察者)设计模式
date: 2018-03-27
categories: php
tag: php
---

# SplSubject 接口中的方法

方法声明 | 描述
---|---
abstract public void attach ( SplObserver $observer ) | 添加（注册）一个观察者
abstract public void detach ( SplObserver $observer ) | 删除一个观察者
abstract public void notify ( void ) | 当状态发生改变时，通知所有观察者


```php
/**
 * 被观察目标
 */
class Cattle implements SplSubject
{
    private $_observers;
    private $_name;

    public function __construct($name)
    {
        $this->_observers = new SplObjectStorage();
        $this->_name = $name;
    }

    // 添加一个观察者
    public function attach(SplObserver $observer)
    {
        $this->_observers->attach($observer);
    }

    // 删除一个观察者
    public function detach(SplObserver $observer)
    {
        $this->_observers->detach($observer);
    }

    // 触发观察者update方法
    public function notify()
    {
        foreach ($this->_observers as $observer) {
            $observer->update($this);
        }
    }

    public function getName()
    {
        return $this->_name;
    }
}
```

# SplObserver 中的方法


方法声明 | 描述
---|---
abstract public void update ( SplSubject $subject ) | 在目标发生改变时接收目标发送的通知；当关注的目标调用其notify()时被调用


```php
/**
 * 观察者
 */
class Tommy1 implements SplObserver
{
    // 当被观察目标调用notify方法时触发此方法
    public function update(SplSubject $subject)
    {
        echo __CLASS__ . ' - ' . $subject->getName() . '<br>';
    }
}

/**
 * 观察者
 */
class Tommy2 implements SplObserver
{
    // 当被观察目标调用notify方法时触发此方法
    public function update(SplSubject $subject)
    {
        echo __CLASS__ . ' - ' . $subject->getName() . '<br>';
    }
}
```

# 调用


```php
$user = new Cattle('Cattle');
$user->attach(new Tommy1);
$user->attach(new Tommy2);
$user->notify();

执行结果
Tommy1 - Cattle
Tommy2 - Cattle
```

- SPL为PHP标准库。内容主要包括数据结构类，迭代器，异常类，SPL函数，还有一些接口。
数据结构类主要包括栈，队，堆，数组等基本数据结构，php已经帮你封装好了，如果你要做数据处理可以直接拿来用，很方便