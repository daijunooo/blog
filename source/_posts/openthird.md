---
title: 微信第三方授权流程
date: 2018-08-26
categories: php
tag: php 微信
---

# 白话说流程
- 此篇仅针对微信第三方小程序开发流程，公众号可以点击右上角关闭浏览器了。
> 在说正题之前，我想说一个小故事。人送外号刀哥（卖白粉的），刀哥今天要去备货，到了交易的地点后他掏出一张卡片，发货的人接过卡片一看，二话没说把货交给了刀哥。其他像刀哥一样来交易的人也都是靠卡片来拿货。后来越来越多的像砖哥、枪哥、拳哥等等的都操持起了卖白粉的业务，但是由于他们只善于干架，对做生意是一窍不通，所以他们都把生意交给我来打理。由于我是个良民😜，所以我手上没有卡片。我只好去白粉供应商（简称粉商）那里签一份协议。审核通过后每隔10分钟粉商会发一条短信临时卡给我，我带着临时卡去可以换成一张正式卡，但是光有正式卡还不能替他们拿货，我还需要用我的正式卡和他们一起去白粉协会换一张代理卡，有了代理卡后我就可以操作一切大哥们授权给我的业务。就这样我成了一大代理商。我和粉商之间的业务往来用我的正式卡，我替大哥们打理生意用代理卡。
- 故事说完了，我就是微信第三方平台，大哥们就是授权给我的小程序，粉商就是微信接口，大哥们的卡就是access_token,我的临时卡是component_verify_ticket，我的正是卡就是component_access_token，我的代理卡就是authorizer_access_token。
- 简单说就是我拿着代理卡可以帮大哥们赚钱。后面我会详细介绍怎么拿到这张代理卡，微信第三方授权的目的就是拿到代理卡，也就是authorizer_access_token。

# 微信第三方授权流程
### step.1 （和粉商签协议，获取临时卡）
- 申请微信第三方平台
- 出于安全考虑，在第三方平台创建审核通过后，微信服务器 每隔10分钟会向第三方的消息接收地址推送一次component_verify_ticket（临时卡）
- 以下代码仅供参考，在开发这个功能时，由于不清楚微信发送过来的数据结构，所以最好把发过来的参数全部写入文件，然后打开后用接口工具模拟同样的入参来继续开发。

``` php
public function getAuthorize(Wxthird $wxthird)
{
    //微信服务器发过来的加密信息
    $params = request()->param();
    $in = file_get_contents('php://input');
    //解密verify_ticket(返回XML格式)
    $decryptMsg = $wxthird->decryptVerifyTicket($params['msg_signature'], $params['timestamp'], $params['nonce'], $in);
    //保存到数据库
    $data = ['name' => 'verify_ticket_post', 'val' => json_encode($params), 'id' => 1];
    $wxthird->add($data);
    $data = ['name' => 'verify_ticket_get', 'val' => $in, 'id' => 2];
    $wxthird->add($data);
    $data = ['name' => 'verify_ticket', 'val' => $decryptMsg, 'id' => 3];
    $wxthird->add($data);

    return 'success';
}
```

### step.2（换取正式卡）
- 第三方平台通过自己的component_appid（即在微信开放平台管理中心的第三方平台详情页中的AppID和AppSecret）和component_appsecret，以及component_verify_ticket（每10分钟推送一次的安全ticket）来获取自己的接口调用凭据（component_access_token）

``` php
public function getComponentAccessToken()
{
    //根据用户component_verify_ticket获取用户component_access_token字段;
    $post_data = [
        "component_appid" => $this->component_appid,
        "component_appsecret" => $this->component_appsecret,
        "component_verify_ticket" => $valString
    ];
    $res = $this->_request($this->wxThirdApiUrl['api_component_token'], json_encode($post_data));

    return json_decode($res)->component_access_token;
}
```

### step.3（此步骤理解为我和粉商的业务）
- 前面说过我和粉商的业务是通过我的正式卡进行的
- 获取预授权码pre_auth_code
- 第三方平台通过自己的接口调用凭据（component_access_token）来获取用于授权流程准备的预授权码（pre_auth_code）


``` php
public function getPreAuthCode()
{
    //拼接url
    $url = $this->wxThirdApiUrl['api_create_preauthcode'] . $this->getComponentAccessToken();
    $post_data = [
        "component_appid" => $this->component_appid,
    ];
    //获取用户pre_auth_code;
    $res = $this->_request($url, json_encode($post_data));

    return json_decode($res)->pre_auth_code;
}
```

### step.4（获取代理卡）
- 此步骤需要我的正式卡和大哥们的授权（授权码）
- 所以需要通过网页扫码授权，此步骤可以查看微信文档，这里就略过了
- 通过授权码和自己的接口调用凭据（component_access_token），换取公众号或小程序的接口调用凭据（authorizer_access_token和用于前者快过期时用来刷新它的authorizer_refresh_token）和授权信息（授权了哪些权限等信息）


``` php
public function getAuthAccessToken($authorizer_appid)
{
    $post_data = [
        "component_appid" => $this->component_appid,
        "authorizer_appid" => $authorizer_appid,
        "authorizer_refresh_token" => $authorizer_refresh_token
    ];
    $re = $this->_request($url, json_encode($post_data));
    //拼接原始的权限数据和appid数据;
    $res = json_decode($re);

    return $res->authorizer_access_token;
}
```

# 完结
- 今天总算抽时间把这个流程理清楚了，可能里面有一些细节会疏漏，大体就是这么个样子了。
- 以上代码摘自组内开发小伙伴的，感谢他。没有经过他同意😅