manager-for-uypun
=====

manager-for-uypun 是一个又拍云资源管理器，使用它您可以上传、下载和管理您储存于又拍云空间中的文件资源。该项目已得到又拍云官方的赞助和开发支持，详情请参见下文的“支持”章节。

又拍云是一个非结构化数据云存储、云处理、云分发平台，关于又拍云的详细介绍请参见[又拍云官方网站](https://www.upyun.com/)。没有又拍云帐号？可以使用这个公用的演示帐号登录：

```
用户名: demo
密码: demo123456
空间名: manager-demo
```

Windows 版本安装后，可以直接在“运行”或者地址栏中直接打开以下地址来登录演示空间：

```
upyun://demo:MD5_bed3482f502c7bbfb6f9fa54f36e77d7@manager-demo/
```

下载
------

* 当前版本： 0.0.6 (更新于2014-06-01)
* [Mac](http://micyin.b0.upaiyun.com/manager-for-upyun/manager-for-upyun-0.0.6-osx.zip)
* [Windows](http://micyin.b0.upaiyun.com/manager-for-upyun/manager-for-upyun-0.0.6-win32.exe)
* Linux [32位](http://micyin.b0.upaiyun.com/manager-for-upyun/manager-for-upyun-0.0.6-linux-ia32.zip) [64位](http://micyin.b0.upaiyun.com/manager-for-upyun/manager-for-upyun-0.0.6-linux-x64.zip)

![screenshot-0.0.6-1.png](http://micyin.b0.upaiyun.com/manager-for-upyun/screenshot-0.0.6-1.png)

![screenshot-0.0.6-2.png](http://micyin.b0.upaiyun.com/manager-for-upyun/screenshot-0.0.6-2.png)

![screenshot-0.0.6-3.png](http://micyin.b0.upaiyun.com/manager-for-upyun/screenshot-0.0.6-3.png)

![screenshot-0.0.6-4.png](http://micyin.b0.upaiyun.com/manager-for-upyun/screenshot-0.0.6-4.png)

![screenshot-0.0.6-5.png](http://micyin.b0.upaiyun.com/manager-for-upyun/screenshot-0.0.6-5.png)

发布说明
------

0.0.6 (更新于2014-06-01)

* 修改登录界面的外观
* 升级至 node-webkit 0.9.2 修正了文件夹选定的问题，并增强了稳定性

0.0.5 (更新于2014-05-26)

* 显示单个文件上传的进度
* (Windows) 可以分享和打开特定目录的 upyun://... 地址
* 可以将公共地址复制到剪切板
* 可以创建文件
* 不再使用 SSL 接入点，并且使用了摘要授权
* 在工具栏上加入下载和上传的按钮

0.0.3 (更新于2014-04-28)

* 完成文件和文件夹的拖拽上传
* 完成文件和文件夹的下载
* 基本的收藏夹功能

功能开发路线
------

- [x] 收藏夹
- [x] 文件浏览
- [x] 文件删除
- [x] 下载整个目录或单个文件
- [x] 拖拽上传整个目录或单个文件
- [x] 可以取消、看到进度、多个请求同时进行的操作
- [x] 快速筛选列表
- [x] 快速编辑文本文件
- [x] 递归删除目录里的内容以确保成功删除
- [x] 通过类似`upyun://...`的链接打开 & 分享特定目录
- [ ] 美化界面，以和又拍云管理面板的视觉风格统一
- [ ] 更新提示
- [ ] 移动、重命名文件和目录

使用的技术
------

* node-webkit
* middleman
* ace editor

支持
------

该项目已得到又拍云官方的赞助和开发支持，关于项目的问题和建议亦可在[“又拍云储存讨论区@segmentfault”](http://segmentfault.com/upyun)或又拍云官方客服处提出。

源码授权
------

MIT（详见源代码中的 [LICENSE](LICENSE)）
