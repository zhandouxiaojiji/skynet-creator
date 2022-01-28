# Skynet Creator
skynet是一个非常棒的游戏服务器框架，但由于太过轻量级，无法像其它框架一样做到开箱即用，往往搭建一个新项目的步骤会非常繁琐，要编写Makefile，引入skynet和第三方库，还要写启动配置等。

skynet-creator就是为了解决这问题而生的，它相当于是skynet的脚手架，能一键生成一个全新的skynet项目(包含启动配置，测试示例，Makefile等)，编译过后就能直接上手写lua服务。并且在后续的开发中，也可以使用skynet-creator按需导入第三方库。

## 使用
```sh
# 创建项目
lua main.lua /my/project/path

# 引入第三方库
lua import.lua /my/project/path lua-cjson lua-openssl ...

# 查看参数
lua main.lua -h
lua import.lua -h
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
|  包名   | 类型  | 说明 | 来源 |
|  ----  | ----  | ---- | ---- |
| lua-cjson | c | json库 | https://github.com/cloudwu/lua-cjson |
| lua-openssl | c | 各类加解密算法库 | https://github.com/zhongfq/lua-openssl |
| lua-lz4 | c | 字符串压缩 | https://github.com/witchu/lua-lz4 |
| pbc | c | protobuf库 | https://github.com/cloudwu/pbc.git |
| crab | c | 敏感字过滤 | https://github.com/xjdrew/crab |
| lfs | c | lua文件系统 | https://github.com/keplerproject/luafilesystem | 
| jps | c | JPS寻路算法 | https://github.com/rangercyh/jps | 
| luaprofile | c | lua性能分析 | https://github.com/lvzixun/luaprofile |
| uuid | lua  | uuid生成 | https://github.com/Tieske/uuid |
| argparse | lua | lua参数解析 | https://github.com/mpeterv/argparse | 
| behavior3 | lua | 行为树 | https://github.com/zhandouxiaojiji/behavior3lua | 
| fsm | lua | 有限状态机 | https://github.com/unindented/lua-fsm |

更多的c库和lua库已在路上。。。

## TODO
+ 添加luacheck选项
+ 添加精简/缺省/完全等创建选项
+ 启动配置及mongo等配置的生成
+ 常用skynet服务导入