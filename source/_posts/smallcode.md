---
title: 小程序踩过的坑
date: 2018-05-12
categories: xiao
tag: 小程序
---

# 根据已踩过的坑让你走的更丝滑 🤓️

<br>
### 不要对路由Api做封装
- 下面的代码在测试中发现会导致页面卡住跳转失败，换成直接调api就好了
- 测试的页面是选好公众号等待爬虫抓取，正常返回抓取到数据了但页面没跳到文章列表
- 故将所有页面路由都改为直接调微信Api的方式

``` php
//跳转新页面；
topage(url, method) {
  if (__APP._CFG.double) {
    __APP._CFG.double = false;
    if (!method) {
      wx.navigateTo({
        url: url
      })
    }
    if (method == 'redirect') {
      wx.redirectTo({
        url: url
      })
    }
    if (method == 'tab') {
      wx.switchTab({
        url: url
      })
    }
    if(method == 'reLaunch') {
      wx.reLaunch({
        url: url
      });
    }
    if (method == 'back') {
      if (isNaN(url)) {
        wx.navigateBack({
          url: url
        })
      } else {
        wx.navigateBack({
          delta: url
        })
      }
    }
    setTimeout(function () {
      __APP._CFG.double = true
    }, 1000)
  }
},
```

<br>
### 最好不要使用缓存传参数

``` php
- 缓存用多了有时排查问题困难，传参从明确变成不明确，甚至找不到缓存在什么地方写入的
- 会导致页面间的依赖，直接导致了分享功能的页面依赖其他页面写的缓存，不利于分享功能的实现
- 由于手机缓存有时会被清除，可能会导致程序执行意外发生
- 微信开发工具中调试时可以一键复制页面参数，使用缓存就杯具了
- 故代码中所有用到缓存的地方全被我干掉了
```

<br>
### 不推荐使用 function.call(this) 的方式调用方法
- 推荐只是客气客气，开发中必须这样做
- 如果有更好的方式请告诉我

``` php
Page({

  data: {
    info: 'Do not .call'
  }

  onLoad: function (options) {
    sayOne.call(this)  // 不推荐此方式
    sayTwo(this)       // 推荐使用这个
  },

})

/**
 * this是关键字在方法中使用要注意作用域
 * 入参隐藏了，看代码时有时容易懵逼
 * 需要写 var _this = this 以在方法中任意位置使用
 */
function sayOne() {
  var _this = this
  console.log(_this.data.info)
}

/**
 * 此方式的好处是入参明确，并且方法中任意地方都可以用_this
 * 比上一种方式少写了一个 var _this = this 比较优雅
 */
function sayOne(_this) {
  console.log(_this.data.info)
}

```

<br>
### 墙裂推荐不写 var _this = this
- 懒和一劳永逸应该是一个优秀开发者所具备的品质
- 上面的栗子改写一下，看看没有最懒只有更懒
- 一次定义终身受益，任意使用_this，抛弃this
- 彻底告别随处可见的 var _this = this

``` php
var _this

Page({

  data: {
    info: 'Do not .call'
  }

  onLoad: function (options) {
    _this = this
    sayOne.call()
    sayTwo()
    sayGood()
  },

})

function sayOne() {
  console.log(_this.data.info)
}

function sayOne() {
  console.log(_this.data.info)
}

function sayGood() {
  console.log(_this.data.info)
}

```
