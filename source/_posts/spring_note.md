---
title: spring开发笔记
date: 2023-09-11
categories: fun
tag: spring
---

# 单元测试

### 没有入口文件的单元测试

```php
@RunWith(SpringRunner.class)
@SpringBootTest(
        classes = {SmsAutoConfigure.class, RedisAutoConfig.class, ComRedisAutoConfig.class},
        webEnvironment = SpringBootTest.WebEnvironment.MOCK,
        properties = {"spring.cloud.config.enabled=false"}
)
class WeiGeChannelImplTest {

    @Autowired
    private SmsService smsService;

    @Test
    void testWeiGeSms() {
        smsService.send(ChannelEnum.WEIGE, "15955149139", "");
    }
}
```

### stream 排序，允许null值

```php
List<PointsMallGoods> skus = pointsList.stream()
    .sorted(Comparator.comparing(PointsMallGoods::getPoints,Comparator.nullsLast(Long::compareTo)))
                .toList();
```

### webflux 框架

```php
public Flux<SeckillGoods> bindOrChangeGoods(BindGoodsForm form) {

    //这个订阅是spring 框架帮你在return response里面做的
    //隐式订阅需要满足条件，没有触发隐式订阅就需要显示调用 subscribe()
    saveSeckillTime(form.getActId(), form.getTime()).subscribe();

    return Flux.fromIterable(form.getGoodsList())
            .flatMap(goodsBean -> saveSeckillGoods(form.getActId(), goodsBean));
}


public Mono<SeckillGoodsTimeModel> findAllByAct(String actId) {

    SeckillGoodsTimeModel model = new SeckillGoodsTimeModel();

    return getSortTime(actId).switchIfEmpty(Mono.fromCallable(SeckillTime::new))
            .flatMap(seckillTime -> seckillGoodsRepository.findByActId(actId)

                    //把实体收集为集合
                    .collectList()

                    //null会导致后面的流中断订阅，所以需要判空 ，然后补偿一个实例对象
                    .switchIfEmpty(Mono.fromCallable(ArrayList::new))
                    .flatMap(seckillGoods -> {
                        model.setTime(seckillTime);
                        model.setGoods(seckillGoods);
                        return Mono.just(model);
                    }));
}


public Flux<SeckillGoods> bindOrChangeGoods(BindGoodsForm form) {
    return saveSeckillTime(form.getActId(), form.getTime())
    
            // flatMapMany 一次对多次调用
            .flatMapMany(time -> Flux.fromIterable(form.getGoodsList())
                    .flatMap(goodsBean -> saveSeckillGoods(form.getActId(), goodsBean)));
}

```

### 开启 MyBatis-Plus SQL

```php
# 开启 MyBatis-Plus SQL 执行分析插件
mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl

```