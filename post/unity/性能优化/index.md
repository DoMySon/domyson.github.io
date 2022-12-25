# 性能优化




# 模型

- 降低模型面数 （300-1500）

- 遮挡剔除

- LOD

- mesh合批


# 音频

- 短音频使用Wav，长音频使用mp3


# 纹理

## Mipmap

mipmap用于减少渲染的带宽压力，但会有额外的内存开销，一般而言UI是建议关闭的，3D模型看情况开启


## Read/Write


## 纹理尺寸

不同大小的纹理尺寸对内存的占用也是不同，依照项目的实际情况来决定Size


## 格式

+ 由于ETC、PVRTC等格式均为有损压缩，因此，当纹理色差范围跨度较大时，均不可避免地造成不同程度的“阶梯”状的色阶问题。因此，很多研发团队使用RGBA32/ARGB32格式来实现更好的效果。但是，这种做法将造成很大的内存占用

+ ETC1 不支持透明通道问题
    可以通过 RGB24 + Alpha8 + Shader 的方式达到比较好的效果

+ ECT2，ASTC
    但需要设备支持 OpenGL ES3.0

# LOD

unity内置的一项技术，主要是根据目标离相机的距离来断定使用何种精度的模型，减少顶点数的绘制，但代价就是要牺牲部分内存


# Occlusion culling 遮挡剔除

遮挡剔除是用来消除躲在其他物件后面看不到的物件，这代表资源不会浪费在计算那些看不到的顶点上，进而提升性能


# batching

- dynamic batching 

将一些足够小的网格，在CPU上转换它们的顶点，将许多相似的顶点组合在一起，并一次性绘制它们。
无论静态还是动态合批都要求使用相同的材质，动态合批有以下限制：

    + 如果GameObjects在Transform上包含镜像，则不会对其进行动态合批处理

    + 使用多个pass的shader不会被动态合批处理

    + 使用不同的Material实例会导致GameObjects不能一起批处理，即使它们基本相同。

    + [官方25个不能动批的情况](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2FUnity-Technologies%2FBatchBreakingCause)

- static batching

静态合批是将静态（不移动）GameObjects组合成大网格，然后进行绘制。静态合批使用比较简单，PlayerSettings中开启static batching，然后对需要静态合批物体的Static打钩即可，unity会自动合并被标记为static的对象，前提它们共享相同的材质，并且不移动，被标记为static的物体不能在游戏中移动，旋转或缩放。但是静态批处理需要额外的内存来存储合并的几何体。注意如果多个GameObject在静态批处理之前共享相同的几何体，则会在编辑器或运行时为每个GameObject创建几何体的副本，这会增大内存的开销

- [GPU Instancing](https://zhuanlan.zhihu.com/p/70123645)

使用GPU Instancing可以一次渲染(render)相同网格的多个副本，仅使用少量DrawCalls。在渲染诸如建筑、树木、草等在场景中重复出现的事物时，GPU Instancing很有用。

每次draw call，GPU Instancing只渲染相同(identical )的网格，但是每个实例(instance)可以有不同的参数(例如，color或scale)，以增加变化(variation)，减少重复的出现。

GPU Instancing可以减少每个场景draw calls次数。这显著提升了渲染性能。

# Physics






# Unity 托管内存

1. 用户代码分配的内存本质上在 `IL2CPP` 构建的 `VM` 的托管内存(`Managed Memory`)上，所以用户代码分配遵从于这个 `VM` 的分配方式。

2. `IL2CPP` 采用的是 `Boehm` 回收算法,这算法的缺陷是 `不分代`，`不压缩`，虽然提高了效率，但由于用户申请内存的不确定性，容易造成内存碎片，不利于此块的内存重使用。

3. 内存以 `Block` 来管理，当一个 `Block` 6次GC没有被访问，才会返回给 OS。

3. `Zombie Memory`,由于用户不主动释放，但实际没有使用。那么这块内存将不会被回收。

4. 对于一个物体，应该是 `Destory` 而不是置为 `Null`。

4. 下一代采用 `渐进式GC`（分帧GC，使CPU峰值更平滑），可以手动开关。

[浅谈Unity内存管理](https://www.bilibili.com/video/av79798486)



# 分析工具

UnityProfiler，UWA
