# Skynet Creator
skynet是一个非常棒的游戏服务器框架，但由于太过轻量级，对新手不太友好，无法像其它框架一样做到开箱即用，往往搭建第一个helloworld的启动配置Makefile等就让新手知难而退。

skynet-creator就是为了解决这问题而生的，它相当于是skynet的脚手架，能一键生成一个全新的skynet项目(包含启动配置，测试示例，Makefile等)，编译过后就能直接上手写lua服务。并且在后续的开发中，也可以使用skynet-creator很方便的导入第三方库。

## 使用
```sh
# 创建项目
lua main.lua /your/project/path

# 引入第三方库
lua import.lua /your/project/path module1 module2 ...

# 查看参数
lua main.lua -h
lua import.lua -h
```

## 示例项目
+ [skynet-creator-sample](https://github.com/zhandouxiaojiji/skynet-creator-sample)

## 第三方库
+ [lua-cjson](https://github.com/cloudwu/lua-cjson.git)
+ [lua-openssl](https://github.com/zhongfq/lua-openssl)
+ [pbc](https://github.com/cloudwu/pbc.git)
+ [lfs](https://github.com/keplerproject/luafilesystem.git)
+ [uuid](https://github.com/Tieske/uuid.git)
+ [argparse](https://github.com/mpeterv/argparse.git)
+ 更多的c库和lua库已在路上。。。