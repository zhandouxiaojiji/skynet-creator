# Skynet Creator
skynet是一个非常棒的游戏服务器框架，但由于太过轻量级，对新手不太友好，无法像其它框架一样做到开箱即用，往往搭建第一个helloworld的启动配置Makefile等就让新手知难而退。

skynet-creator就是为了解决这问题而生的，它相当于是skynet的脚手架，能一键生成一个全新的skynet项目(包含启动配置，测试示例，Makefile等)，编译过后就能直接上手写lua服务。并且在后续的开发中，也可以使用skynet-creator很方便的导入第三方库。

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
| uuid | lua  | uuid生成 | https://github.com/Tieske/uuid |
| argparse | lua | lua参数解析 | https://github.com/mpeterv/argparse | 
| behavior3 | lua | 行为树 | https://github.com/zhandouxiaojiji/behavior3lua | 
| fsm | lua | 有限状态机 | https://github.com/unindented/lua-fsm |

更多的c库和lua库已在路上。。。

## TODO
+ 添加luacheck选项
+ 添加精简/缺省/完全等创建选项