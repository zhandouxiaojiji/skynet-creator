# Skynet Creator
这是一个轻便的skynet脚手架，能一键生成一个全新的项目(包含引用skynet，启动配置，测试示例，Makefile等)，编译过后就能直接上手写lua服务。另外还收藏了一些游戏开发常用的c/lua库还有一些服务，可以在后续的开发中按需导入。

## 使用
```sh
# 安装
make
sudo make install

# 创建项目
skynet-creator create /path/to/new/project

# 导入第三方库
skyent-creator import cjson openssl pbc ...

# 查看参数
skynet-creator --help
```

## 生成项目结构
+ 3rd 引入的第三方库(主要是c库)
+ build 编译目录，所有生成的目标都在这，包括可执行文件skynet,lua还有各种so文件等
+ lualib 引用的lua库，或者是用户自己的lua库
+ service 引用的lua服务，或者是用户自己的lua库
+ make 第三方库的makefile目录，每次编译的时候会遍历这一个目录的所有.mk文件
+ skynet 子模块
+ Makefile 主makefile文件，编译skynet和第三方库
+ test.sh 运行test测试
## 示例项目
+ [skynet-creator-sample](https://github.com/zhandouxiaojiji/skynet-creator-sample)

## 第三方库
+ 需要编译的c库都是以submodule的形式导入项目，导入的时候引用源仓库的主干，最新的文档和说明请参考原仓库。
+ lua和service是直接从creator拷贝过去的(非submodule)，后续有需要的自行手动更新。

|  包名   | 类型  | 说明 | 来源 |
|  ----  | ----  | ---- | ---- |
| cjson | c | json库 | https://github.com/cloudwu/lua-cjson |
| curl | c | curl库 | https://github.com/Lua-cURL/Lua-cURLv3 |
| openssl | c | 各类加解密算法库 | https://github.com/zhongfq/lua-openssl |
| lz4 | c | 字符串压缩 | https://github.com/witchu/lua-lz4 |
| pbc | c | protobuf库 | https://github.com/zhandouxiaojiji/pbc |
| ecs | c | ecs框架 | https://github.com/cloudwu/luaecs |
| crab | c | 敏感字过滤 | https://github.com/xjdrew/crab |
| lfs | c | lua文件系统 | https://github.com/keplerproject/luafilesystem |
| jps | c | JPS寻路算法 | https://github.com/rangercyh/jps |
| navigation | lua | 平滑的网格寻路 | https://github.com/zhandouxiaojiji/lua-navigation |
| profile | c | lua性能分析 | https://github.com/lvzixun/luaprofile |
| snapshot | c | lua快照(检测内存泄漏用) | https://github.com/lvzixun/lua-snapshot |
| uuid | lua  | uuid生成 | https://github.com/Tieske/uuid |
| argparse | lua | lua参数解析 | https://github.com/mpeterv/argparse |
| behavior3 | lua | 行为树 | https://github.com/zhandouxiaojiji/behavior3lua |
| fsm | lua | 有限状态机 | https://github.com/unindented/lua-fsm |
| revent | lua | 远程消息 | https://github.com/zhandouxiaojiji/skynet-remote-event |
| bewater | lua | 一些常用lua库集合 | 原仓库已经弃用，现由skynet-creator继续维护 |
| fog | lua | 迷雾算法 | https://github.com/zhandouxiaojiji/lua-fog |
| crypto | c | 加解密算法库 | https://github.com/zhandouxiaojiji/lua-crypto |
| hex-grid | c | 六边形网格 | https://github.com/zhandouxiaojiji/lua-hex-grid |
| packet | c | 二进制流打包与解析 | https://github.com/zhandouxiaojiji/lua-packet |
| bytebuffer | c | 二进制流打包与解析 | https://github.com/zhandouxiaojiji/lua-bytebuffer |
| quadtree | c | 四叉树 | https://github.com/rangercyh/quadtree |

更多的c库和lua库已在路上，大佬们有发现什么好用的库，欢迎pr

## 相关库安装
如果生成的项目在make的时候报缺失相关依赖，可以参考以下脚本
### ubuntu
```shell
sudo apt-get install autoconf
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install openssl libssl-dev
sudo apt-get install build-essential
```

### centos
```shell
sudo yum install autoconf
sudo yum install curl-devel
sudo yum install openssl-devel
```

### 配置luacheck
```shell
skynet-creator import luacheck #配置默认的.luacheckrc，并安装git pre-commit钩子
```

## TODO
+ 添加精简/缺省/完全等创建选项
+ 启动配置及mongo等配置的生成
+ 常用skynet服务导入
