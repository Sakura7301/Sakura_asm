## 实现流程:
#####    1.BIOS首先把bootloader加载到内存
#####    2.bootloader开始运行,并把program加载到内存
#####    3.program开始运行,输出字符串到屏幕


## bootloader需要知道什么?
#####    从哪儿开始读取?读几个扇区?
#####    程序是否分段?分了几个段?段地址是多少?
#####       -->必须由program告诉bootloader
#####    栈的位置需要重新计算,即重定位
#####    程序的入口点在哪儿?
#####       -->必须由program告诉bootloader



#### 既然有这么多信息都需要告诉bootloader,那我们干脆为program写一份"简历",把这些事情说清楚即可
## 包含内容如下:
#####    大小    SIZE
#####    段地址  SegmentAddr
#####    段数量  SegmentNum
#####    入口点  Entry
 


## program的结构:
#####    "简历"->head
#####    代码段->code
#####    数据段->data
#####    栈段->stack
#####    结束段->end


## bootloader的结构:
#####  读取第一个扇区
#####  根据程序大小,读取剩余扇区并加载到指定内存
#####  对程序的段地址以及入口的重定位
#####  跳转至程序入口

**将program.bin写入1号扇区,将bootloader.bin写入0号扇区,启动虚拟机即可**
