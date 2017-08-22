manager-for-upyun
=====

manager-for-upyun 是一个又拍云资源管理器，使用它您可以上传、下载和管理您储存于又拍云空间中的文件资源。

又拍云是一个非结构化数据云存储、云处理、云分发平台，关于又拍云的详细介绍请参见[又拍云官方网站](https://www.upyun.com/)。没有又拍云帐号？可以使用这个公用的演示帐号登录：

```
操作员：layerssss
操作员密码：MD5_f92a36b6eb4d964c1b64cc008ecac009
空间名：manager-for-upyun
```

可以直接在打开以下地址来登录演示空间：

```
upyun://layerssss:MD5_f92a36b6eb4d964c1b64cc008ecac009@manager-for-upyun/
```

下载
------

* 当前版本： 0.0.7 (更新于2017-08-22)
* [Windows / Mac / Linux](https://github.com/layerssss/manager-for-upyun/releases)

![01.png](screenshots/01.png)
![02.png](screenshots/02.png)
![03.png](screenshots/03.png)

发布说明
------

0.0.7 (更新于2017-08-22)

* 将 node-webkit 更换为 Electron
* 将 middleman 更换为 webpack

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

* Electron
* webpack
* ace editor

源码授权
------

MIT（详见源代码中的 [LICENSE](LICENSE)）
