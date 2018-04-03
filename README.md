# LVFrameAnimation
iOS - 试图解决帧动画存在的一些问题的demo

> [iOS内存优化基础](https://www.jianshu.com/p/c58001ae3da5)
[腾讯帧动画优化方案](https://segmentfault.com/a/1190000007131210)


## 基础内存优化

### 1.I/O性能优化

减少I/O次数是性能优化的关键点：
- 将零碎的内容作为一个整理进行写入
- 使用合适的I/O操作API
- 使用合适的线程
- 使用NSCache做缓存能够减少I/O

#### 1-1.NSCache

- 自动清理系统占用的内存
- NSCache线程安全
- 缓存对象被清理时会有回调
- 可以控制是否清理

### 2.内存性能

突然的大量内存需求是会影响相应的：
- 【强制】优化计算的复杂度从而减少CPU的使用
- 【强制】在应用相应交互的时候停止没必要的任务处理
- 【强制】设置合适的Qos
- 【强制】将定时器任务合并，让Runloop更多时候处于idle状态

### 3.控制App的Wake次数（帧动画暂时不考虑）

通知、VoIP、定位、蓝牙都会使设备被唤醒，唤醒的过程比较大的消耗。


## 图片优化进阶

### 原理分析

#### 1.图片加载解码

比较容易影响性能：
- 加载图片（取决于CPU和I/O）
	- 提前加载图片（可以设置优先级，优先级高的可以预加载。不可以延迟加载，因为延迟加载不能保证每帧提前加载到图片）
- 图片解码（比加载图片更加耗时，博文中测试结果是3倍，iOS默认是在主线程图片解码的，但是解码后的图片太大，一般不会缓存到disk中，但是我可以尝试）

#### 2.缓存

缓存分为原图片的缓存和解码后的位图数据的缓存。

#### 3.渲染
 
3-1.offscreen rendring

图片在绘制当前屏幕的时候，显卡需要进行一次渲染，然后在绘制到当前屏幕。
对于显卡来说，onscreen和offscreen上下文切换时非常昂贵的（设计OpenGL的pipeline和barrier等）。

```
- layer mask
- layer.maskToBounds
- layer.allowGroupOpacity = YES
- layer.opcaity < 1.0
- layer.shouldRasterize = YES
- layer.cornerRadius
- layer.edgeAntialiasingMask
- layer.allowsEdgeAntialiasing
```

3-2.Blending 混合像素颜色是会导致性能问题

### 优化点

- 精灵序列帧
- 提前解码在渲染前，不要渲染了去解码
- 缓存解码后的位图数据 disk 和 内存中，因为有些礼物效果比较普遍使用
- 图像素材像素尽量对其，尽量减少透明像素

> 存在的问题：乱序、 内存占用高、cpu占用高

### 考虑设计的方案

两种场景：
- 全屏序列帧
- 小精灵序列帧

#### 全屏序列帧

1.NSCache缓存（减少I/O）
2.sqlite3持久化解码好的数据（减少I/O，图片加载和解码）
3.线程池，Qos设置UserInitiated（充分利用CPU，并且保证不占过多）
4.加载策略和销毁策略



































