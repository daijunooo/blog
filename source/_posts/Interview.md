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
	label
LEFT JOIN collect ON label.collect_id = collect.id
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

> 改动后给label表的id，label_name字段加联合唯一索引，可以减少重复数据产生从而减少整表的数据增长（代码中需要做用户新增重复标签的逻辑处理），由于这个表就这两个字段，查询时会走索引覆盖，大大提高查询效率。

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