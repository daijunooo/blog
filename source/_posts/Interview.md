---
title: 记一次远程面试
date: 2020-03-07
categories: fun
---

### 某公司的用户需要收藏一件商品，且收藏时可能添加一个或者多个标签，设计一个数据库结构，并且回答下面的问题。
1. 查询某个用户的全部标签的sql  
2. 查询一个图书的最热标签的sql 
3. 在数据量非常大的情况下，如何优化你设计的数据库

### 表设计

1. 用户表 user

id | user_name
---|---
1 | 张丹
2 | 赵四

2. 商品表 goods

id | goods_name
---|---
1 | 哑铃健身教程
2 | 家常菜速成

3. 收藏表 collect

id | user_id | goods_id
---|---|---
1 | 2 | 1 
2 | 1 | 2 

4. 标签表 label

id | collect_id | label_name
---|---|---
1 |  1 | 运动达人
2 |  2 | 吃货必备


### 查询某个用户的全部标签的sql 

``` php
//查询用户张丹的全部标签
SELECT
	label.id,
	label.label_name
FROM
	collect
LEFT JOIN label ON label.collect_id = collect.id
WHERE
	collect.user_id = 1
```

### 查询一个图书的最热标签的sql

``` php
//查询《家常菜速成》的最热标签
SELECT
	label.id,
	label.label_name,
	COUNT(label.id) AS hot_sort
FROM
	collect
LEFT JOIN label ON label.collect_id = collect.id
WHERE
	collect.goods_id = 2
GROUP BY
	label.label_name
ORDER BY
	hot_sort DESC
LIMIT 1
```

### 在数据量非常大的情况下，如何优化你设计的数据库
> 标签表label考虑到每个商品都可以创建一个和多个标签，数据增长速度会很快。不同用户有可能会创建相同的标签造成数据重复，可以将这个表独立出来，具体优化方案如下：

### 标签表 label

id | collect_id | label_name
---|---|---
1 |  1 | 运动达人
2 |  2 | 吃货必备

### 改为
id | label_name
---|---
1  | 运动达人
2  | 吃货必备

### 增加关联表 collect_label_relation
id | collect_id | label_id
---|---|---
1 | 1 | 1 
2 | 2 | 2

> 改动后给label表的id，label_name字段加联合唯一索引，可以减少重复数据产生从而减少整表的数据增长（代码中需要做用户新增重复标签的逻辑处理），查询时会走索引覆盖，大大提高查询效率。

### 改动后上面的两个sql问题改写为如下：

``` php
//查询用户张丹的全部标签
SELECT
	l.id,
	l.label_name
FROM
	collect AS c
LEFT JOIN collect_label_relation AS clr ON clr.collect_id = c.id
LEFT JOIN label AS l ON l.id = clr.label_id
WHERE
	c.user_id = 1
	
	
//查询《家常菜速成》的最热标签
SELECT
	l.id,
	l.label_name,
	count(l.id) AS hot_sort
FROM
	collect AS c
LEFT JOIN collect_label_relation AS clr ON clr.collect_id = c.id
LEFT JOIN label AS l ON l.id = clr.label_id
WHERE
	c.goods_id = 2
GROUP BY
	clr.label_id
ORDER BY
	hot_sort DESC
LIMIT 1
```

### 针对业务（问题1和2）可以继续优化

### 增加用户与标签的关联表 user_label_relation
id | user_id | label_id
---|---|---
1  | 1 | 1
2  | 1 | 2

### 增加商品与标签的关联表 goods_label_relation
- goods_id，label_id字段加联合唯一索引（插入数据时代码需要做逻辑处理），不同用户的重复数据用count来计数
id | goods_id | label_id | count
---|---|---|---
1  | 1 | 1 | 1
2  | 1 | 2 | 2

> 增加了这个两个关联表后，问题1和2的sql语句会变得简单，减少了join连表。提高了查询效率，但同时也会增加新增编辑时的处理逻辑。优化的方式有很多，比如可以把商品关联的标签全部存储在一个字段中，可以大大减少关联表的数据量，不过这都需要结合具体业务场景做取舍。

### 总结
- 大部分的优化都需要根据业务来做，以上的优化案例是以增加数据冗余来提高查询效率的，也可以说是用写入的效率来换取读的效率，如果数据库写的压力较大以上的优化就不太适合了，但大部分系统都是读的压力较大。
- 优化数据库就像整理衣服一样，如果衣服全堆在床上找起来就慢（全表扫描），按照颜色或款式分类后放入衣柜（范式设计），把衣服贴上序号记录在本子上（建立索引），衣服太多可以多搞几个不同颜色的衣柜（分库分表），平常经常要穿的衣服单独存放（加入缓存），买更高级的分类衣柜（换更好的数据库）。
