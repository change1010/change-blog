---
title: 【Quartus II】Quartus II版本问题导致USB-Blaster驱动更新报错[代码：39/52]
date: 2026-07-31
category: FPGA
cover: https://change1010.github.io/change-blog/image/quartus.webp
summary: 这篇文章主要记录quartus ii在安装USB-Blaster驱动时遇到的报错问题
---

这篇文章主要记录quartus ii在安装USB-Blaster驱动时遇到的报错问题

## 参考教程

- [野火官方教程：第三讲 - FPGA 开发环境的搭建](https://www.bilibili.com/video/BV17z411i7er/?vd_source=dd1289d2d54437314cc320323176dba3)

## 问题描述

### Quartus II 13.0：代码 39

最开始按照野火教程下载了同版本的quartus ii 13.0，但是在安装USB-Blaster驱动时，遇到了如下报错

```text
Windows 无法加载这个硬件的设备驱动程序。驱动程序可能已损坏或不见了。 (代码 39)
```

首先根据网上的相关方法：[【FPGA】Quartus II安装Altera USB-Blaster安装驱动程序出现问题（代码39）的解决办法](https://www.cnblogs.com/Skyrim-sssuuu/p/18817257)关闭内存完整性，无效。

后看到这篇文章：[USB-Blaster驱动安装失败 Code 39](https://blog.csdn.net/u011545492/article/details/115539834)，意识到应该是旧版本quartus ii不兼容win11导致。

根据文中指引，在Altera 社区中找到该篇文章：[Windows cannot load the device-driver for this software. The driver may be corrupted or missing (Code: 39)](https://community.altera.com/kb/knowledge-base/windows-cannot-load-the-device-driver-for-this-software-the-driver-may-be-corrup/348474)，然而该文章版本对应的是win10版本，最终还是选择了卸载重装更新版本的quartus ii 18.1（参考文章：[Quartus18.1标准版的下载安装以及联合Modelsim使用](https://blog.csdn.net/m0_66360845/article/details/145574280)）。

### Quartus II 18.1：代码 52

在quartus ii 18.1又遇到了如下报错
```text
Windows 无法验证此设备所需的驱动程序的数字签名。 (代码 52)
```
通过“禁用驱动程序强制签名”完美解决（参考文章：[解决Windows安装驱动错误代码52：数字签名验证失败](https://blog.csdn.net/qq_34255385/article/details/151801277)）。

更正（2026.8.2）：上文提到的“禁用驱动程序强制签名”方法，只能生效一次，太过于麻烦。最终找到了最完美的解决办法，参考文章：[WIN11 极简安装USB-Blaster驱动](https://blog.csdn.net/Nautiluss/article/details/161118052)。
