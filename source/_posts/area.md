---
title: 标准 省-市-区-乡镇 行政区划数据爬取
date: 2017-11-17
categories: fun
tag: php 爬虫
---

# 背景故事

- 客户需要标准 省-市-区-乡镇 的行政区划代码。
- 在国家统计局发现有 省-市-区 的，到乡镇到县的也有，不过全是html页面😂，好在公司ceo给我提供了一份，项目后期发现数据缺失严重，没有东莞和中山市的数据，得知ceo给的是csdn上别人用爬虫爬的。
- 没办法，网上的数据太不可信了，用了一下午爬了一个完整的。
- 自己爬才发现有坑，csdn的那位兄台估计就是爬来玩的，没有测试数据完整性。

# 爬虫代码

``` php
$dsn = '*****';
$db = new PDO($dsn, 'root', '*****');
header("Content-type: text/html; charset=gb2312");
$index = file_get_contents("http://www.stats.gov.cn/tjsj/tjbz/tjyqhdmhcxhfdm/2016/index.html");
preg_match_all('/<a href=\'(\d{2,4}).html\'>(.{3,20})<br\/><\/a>/', $index, $matches);
echo '<pre>';
$url = 'http://www.stats.gov.cn/tjsj/tjbz/tjyqhdmhcxhfdm/2016/';
error_reporting(0);
$prov = array(
    array(),
    array(
        11,
        12,
        13,
        14,
        15,
        21,
        22,
        23,
        31,
        32,
        33,
        34,
        35,
        36,
        37,
        41,
        42,
        43,
        44,
        45,
        46,
        50,
        51,
        52,
        53,
        54,
        61,
        62,
        63,
        64,
        65
    ),
    array(
        '北京市',
        '天津市',
        '河北省',
        '山西省',
        '内蒙古自治区',
        '辽宁省',
        '吉林省',
        '黑龙江省',
        '上海市',
        '江苏省',
        '浙江省',
        '安徽省',
        '福建省',
        '江西省',
        '山东省',
        '河南省',
        '湖北省',
        '湖南省',
        '广东省',
        '广西壮族自治区',
        '海南省',
        '重庆市',
        '四川省',
        '贵州省',
        '云南省',
        '西藏自治区',
        '陕西省',
        '甘肃省',
        '青海省',
        '宁夏回族自治区',
        '新疆维吾尔自治区'
    )
);

$matches = $prov;

for ($i = 0,$e = count($matches[1]); $i < $e; $i++) {
    $index = file_get_contents($url.$matches[1][$i].'.html');
    preg_match_all('/<a href=\'\d{2}\/(.{1,30}).html\'>(.{1,30})<\/a><\/td><\/tr>/', $index, $matche);
    /*$matche = array(
        array(),
        array(4419),
        array('东莞市')
    );*/
    for ($a = 0,$b = count($matche[1]); $a < $b; $a++) {
        $index = file_get_contents($url.$matches[1][$i].'/'.$matche[1][$a].'.html');
        preg_match_all('/<a href=\'\d{2}\/(.{1,30}).html\'>(.{1,30})<\/a><\/td><\/tr>/', $index, $match);
        for ($c = 0,$d = count($match[1]); $c < $d; $c++) {
            $aru = substr($matche[1][$a], 2, 2);
            $index = file_get_contents($url.$matches[1][$i].'/'.$aru.'/'.$match[1][$c].'.html');
            preg_match_all('/<a href=\'\d{2}\/(.{1,30}).html\'>(.{1,30})<\/a><\/td><\/tr>/', $index, $matc);



            //坑在这里，部分省市的html和大部分的不一样，所以正则匹配不到😂
            if (!$matc[0]) preg_match_all('/<td>(.{1,30})<\/td><td>\d{1,10}<\/td><td>(.{1,30})<\/td><\/tr>/', $index, $matc);


            $sql = 'REPLACE INTO position (province_id,province_name,city_id,city_name,county_id,county_name,town_id,town_name) VALUES ';
            for ($v = 0,$n = count($matc[1]); $v < $n; $v++) {
                $jil = iconv("utf-8", "gbk//ignore", $matches[2][$i]);
                $sql .= "({$matches[1][$i]},'{$jil}',{$matche[1][$a]},'{$matche[2][$a]}',{$match[1][$c]},'{$match[2][$c]}',{$matc[1][$v]},'{$matc[2][$v]}'),";
            }
            $sql = iconv("gbk", "utf-8//ignore", $sql);
            $res = $db->query(rtrim($sql, ","));
            usleep(200000);
        }
    }
}
```