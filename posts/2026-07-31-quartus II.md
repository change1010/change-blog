---
title: 【Quartus II】Quartus II版本问题导致USB-Blaster驱动更新报错[代码：39/52]
date: 2026-07-31
category: FPGA
cover: https://change1010.github.io/change-blog/image/OIP-C.jpg
summary: 这篇文章主要记录quartus ii在安装USB-Blaster驱动时遇到的报错问题
---

这篇文章主要记录quartus ii在安装USB-Blaster驱动时遇到的报错问题

## 参考教程

- [野火官方教程：第三讲 - FPGA 开发环境的搭建](https://www.bilibili.com/video/BV17z411i7ers)

## 问题描述

### Quartus II 13.0：代码 39

最开始按照野火教程下载了同版本的quartus ii 13.0，但是在安装USB-Blaster驱动时，遇到了如下报错

```text
Windows 无法加载这个硬件的设备驱动程序。驱动程序可能已损坏或不见了。 (代码 39)
```

首先根据网上的[相关方法](https://www.cnblogs.com/Skyrim-sssuuu/p/18817257)关闭内存完整性，无效。

后看到[这篇文章](https://blog.csdn.net/u011545492/article/details/115539834)，意识到应该是旧版本quartus ii不兼容win11导致。

根据文中指引，在[Altera 社区](https://community.altera.com/kb/knowledge-base/windows-cannot-load-the-device-driver-for-this-software-the-driver-may-be-corrup/348474)中找到该篇文章，然而该文章版本对应的是win10版本，最终还是选择了卸载重装更新版本的quartus ii 18.1（参考[文章](https://blog.csdn.net/m0_66360845/article/details/145574280)）。

### Quartus II 18.1：代码 52

在quartus ii 18.1又遇到了如下报错
```text
Windows 无法验证此设备所需的驱动程序的数字签名。 (代码 52)
```
通过“禁用驱动程序强制签名”完美解决（参考[文章](https://blog.csdn.net/qq_34255385/article/details/151801277)）。
