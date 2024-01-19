---
title: spring注解（不断完善中）
date: 2022-12-08
categories: fun
tag: spring java
---

# 分类

#### 从广义上Spring注解可以分为两类：

- 一类注解是用于注册Bean,比如@Component, @Repository, @Controller, @Service, @Configration，这些注解就是用于注册Bean，放进IOC容器中

- 一类注解是用于使用Bean,比如@Autowired、@Resource注解，这些注解就是把屋子里的东西直接拿来用

![image](https://s1.ax1x.com/2023/03/09/ppn8I9U.png)

# 注解

### @Configuration

- @Configuration用于定义配置类，可替换xml配置文件，被注解的类内部包含有一个或多个被@Bean注解的方法
- 这些方法将会被AnnotationConfigApplicationContext或AnnotationConfigWebApplicationContext类进行扫描，并用于构建bean定义，初始化Spring容器。
- 配合 META-INF/spring.factories 可以实现自动装配

```php
// spring.factories 文件示例
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
com.billbear.common.sms.config.SmsAutoConfigure
```

### @ConfigurationProperties

- 可以直接自动从Springboot的配置文件如：application.yml 或application.properties中读取配置到java类

### @EnableConfigurationProperties

- 使使用 @ConfigurationProperties 注解的类生效

```php
@EnableConfigurationProperties(SmsProperties.class)
public class SmsAutoConfigure {

    @Autowired
    private SmsProperties smsProperties;

}
```

### 条件注解(用于注册Bean，通过条件)

```php
@Conditional                     作用（判断是否满足当前指定条件）
@ConditionalOnJava               系统的java版本是否符合要求
@ConditionalOnBean               容器中存在指定Bean
@ConditionalOnMissingBean        容器中不存在指定Bean
@ConditionalOnExpression         满足SpEL表达式指定
@ConditionalOnClass              系统中有指定的类
@ConditionalOnMissingClass       系统中没有指定的类
@ConditionalOnSingleCandidate    容器中只有一个指定的Bean，或者这个Bean是首选Bean
@ConditionalOnProperty           系统中指定的属性是否有指定的值
@ConditionalOnResource           类路径下是否存在指定资源文件
@ConditionalOnWebApplication     当前是web环境
@ConditionalOnNotWebApplication  当前不是web环境
@ConditionalOnJndi               JNDI存在指定项
```

