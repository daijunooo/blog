---
title: linux配置用户sftp只能访问指定目录
date: 2022-2-23
categories: fun
tag: linux
---

# 修改 sftp 配置

``` php
vim /etc/ssh/sshd_config
```

- 新增 Subsystem       sftp    internal-sftp

``` php
#Subsystem      sftp    /usr/libexec/openssh/sftp-server
Subsystem       sftp    internal-sftp
```

- 在最后追加


``` php
Match User www-data
     ChrootDirectory /www/site/dev/framework
     ForceCommand internal-sftp
     AllowTcpForwarding no
     X11Forwarding no
```

> /www/site/dev/framework 每级目录用户和用户组必须是root:root

# 重启服务

``` php
service sshd restart
```

# 最佳实践
- 可以单独建一个目录作为指定用户可以访问的目录，例如 /home/user
- 其他需要给这个用户访问的目录可以挂载到 /home/user
- 这样就可以自定义哪些目录可以指定给这个用户访问，可以实现自由组合
- ChrootDirectory 配置到这个 /home/user 目录

``` php
# 挂载目录
mount --bind /www/data /home/user/data

# 取消挂载 
umount /home/user/data
```

