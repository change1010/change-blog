---
title: 【盘古100Pro+开发板】对网上常见的PDS下载与安装教程纠错
date: 2026-07-14
category: FPGA
cover: https://change1010.github.io/change-blog/image/%E5%B0%8F%E7%B4%AB%E5%B0%BA.png
summary: 希望该文章能解决小白入门紫光同创FPGA所遇到的软件适配问题-1
---

这篇文章主要记录我在使用盘古100Pro+开发板时，安装和配置PDS遇到的一些问题。

网上能找到不少PDS下载和安装教程，但其中很多教程并不完全适合盘古100Pro+。如果直接照着旧教程安装，可能会遇到器件库缺失、芯片无法识别、license配置不正确等问题。

参考教程：

- 小眼睛科技官方安装教程：https://blog.csdn.net/MYMINIEYE/article/details/134313667
- 逻辑矩阵技术论坛：https://www.szlogicmatrix.com/
- 紫光同创官网：https://www.pangomicro.com/

## 为什么写这篇文章

紫光同创官方的开发资料实在是难以入目。很多文档会同时覆盖多个开发板，步骤也经常只讲到一半，初学者很容易不知道自己到底应该下载哪个版本、安装哪些组件、配置哪些文件。

对盘古100Pro+来说，最容易踩的坑是PDS版本不匹配。

网上流传的一些 PDS 旧版本，尤其是 PDS 2021 以及更早版本，通常没有 `Logos2 PG2L100H` 器件库。因此安装完成后，软件可能无法识别盘古 100Pro+ 使用的芯片。

## 推荐版本

学习和使用盘古 100Pro+ 开发板时，建议优先使用：

```text
PDS 2022.2-SP6.4 win64
```

这个版本对盘古 100Pro+ 的适配相对稳定，也更容易找到对应的器件支持。

## 下载与资料入口

PDS 安装包和相关资料建议优先通过官方渠道获取。

这里附上从官方客服获取的软件及license下载地址：

PDS_2022.2-SP6.4-win64

链接: https://pan.baidu.com/s/1V7j_bEHNM47Jd_5t0tQvKw 

提取码: 4j8v 

小眼睛FPGA--license

链接: https://pan.baidu.com/s/1hgaunRgukaKtqln24xIY6g 

提取码: gjtj 

配套资料查阅及下载、技术答疑请登录逻辑矩阵技术论坛https://www.szlogicmatrix.com/

## 关于 license 的提醒

网上所流传的PDS免license版（一般为Lite版或老版本）

非Lite版本的PDS通常需要license。然而，即便是官方客服给的license文件，依旧是靠TAP-Windows软件来制造虚拟网卡从而跳过验证，并非实实在在的官方license。

其操作原理如下：

安装 TAP 虚拟网卡 → 修改虚拟网卡 MAC 匹配共享 lic 文件 → 配置环境变量PANGO_LICENSE_FILE加载破解 lic，绕过官方授权校验

如需获得最正规的license文件，需要在紫光同创官网（https://www.pangomicro.com）注册账户并申请，这一般需要3-5天的时间（原因是紫光为人工审核）。

