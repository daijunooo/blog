---
title: 还在用canvas画小程序分享海报？
date: 2019-04-09
categories: fun
tag: phantomJs
---

### 小程序海报的痛点
- 不管是前端还是后端去画都得一点一点慢慢调样式
- 文字大小和换行不好控制
- 一旦需求一变又得重新微调样式，很费时间

### 把画图转化成截图解决以上痛点
- 海报用html去写，访问html页面看到的效果就是海报图片的效果
- 换海报就是换html，告别canvas，再也不怕需求变更

### 架构解决方案
- phantomJs搭建截图服务
- 写个html页面作为海报模版
- 小程序用户生成海报时动态替换html内容，交给截图服务截图即可拿到分享海报图

### 截图服务端demo

``` php
var webserver = require('webserver');
var server = webserver.create();
var webpage = require('webpage');

var service = server.listen(8181, function (request, response) {

  var page = webpage.create(), address;

  //请求超时时间
  page.settings.resourceTimeout = 5000;

  //关闭js提高效率
  page.settings.javascriptEnabled = false;

  //海报截图的尺寸
  page.viewportSize = {width: 750, height: 1334};

  //html访问地址
  address = request.url.substr(4);

  page.open(address, function (status) {
    if (status !== 'success') {
      console.log('Unable to load the address!');
      response.write(0);
    } else {
      console.log(address);

      //返回页面截图base64字符串
      var base64 = page.renderBase64('PNG');

      //写入响应
      response.write(base64);
    }

    //响应请求
    response.close();

    //关闭
    page.close();
  });

});
```
> 安装phantomJs，运行服务端demo，./phantomjs demo.js

### php端demo

``` php
header("content-type: image/png");
$img = file_get_contents('http://localhost:8181/?a=' . $_GET['a']);
echo base64_decode($img);
```
> 访问http://localhost:8181/?a=https://www.github.com,不出意外将得到github主页的一张png图片，以上流程跑通就可以按实际业务开发任何生成海报的需求了。

### 注意事项
- phantomJs最高并发10，超过了需要搭建多个服务，截图时cpu和内存占用可能较高，并且可能出现内存泄露，需要有这方面的考虑并设计应对方案
- page.settings.javascriptEnabled = false，关闭了js文件解析会大大减少内存使用，同时html中如果有js将不会解析执行，所以动态替换html只能交给后端处理，不能使用js
- page.close()这行代码一定要有，否则一定会出现内存泄露的情况

### 欣赏一下phantomjs截的两张网页
1. 百度图片
![image](http://daijunooo-img.test.upcdn.net/blog/baiduimg.png)

2. composer
![image](http://daijunooo-img.test.upcdn.net/blog/composerimg.png)
