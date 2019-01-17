---
title: C语言求水仙花数
date: 2018-03-24
categories: fun
tag: 算法
---

# C语言求水仙花数

- 最近在看C语言,于是就想到了上篇博客,php多线程算水仙花数.干脆用C再算一次看看效率

```php
#include <stdio.h>
#include <math.h>

void narcissus(int start, int end) {

    int length, i, j, o, num[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    for (start; start <= end; start++) {

        for (i = 10, j = 0; 1; i *= 10, j++) {
            num[j] = (int) floor(start % i / (i / 10));
            if (start < i) {
                length = (int) log10(i);
                break;
            }
        }

        int res = 0;
        for (o = 0; 1; o++) {
            if (0 == num[o]) break;
            res += (int) pow(num[o], length);
        }

        if (res == start) {
            printf("水仙花数:%d\n", res);
        }
    }
}

void main() {
    //定义开始和结束
    int start, end;

    //接受输入
    scanf("%d %d", &start, &end);

    //输出此范围内的所有水仙花数
    narcissus(start, end);
}


千万级内的水仙花数也是10内算完
上次用php算百万级的就要60秒左右
C语言百万级几乎秒出,性能差别挺大的

水仙花数:0
水仙花数:1
水仙花数:2
水仙花数:3
水仙花数:4
水仙花数:5
水仙花数:6
水仙花数:7
水仙花数:8
水仙花数:9
水仙花数:153
水仙花数:371
水仙花数:1634
水仙花数:9474
水仙花数:16807
水仙花数:54748
水仙花数:92727
水仙花数:548834
水仙花数:1741725
水仙花数:9926315
```
