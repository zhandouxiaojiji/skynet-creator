#!/bin/bash

RESOURCES_DIR="/usr/local/share/skynet-creator"
SKYNET_REPO="https://github.com/cloudwu/skynet.git"

function usage() {
    cat <<EOF
用法: skynet-creator [选项] <操作> [参数]

选项:
  -f, --force      如果目标目录已存在，强制覆盖

操作:
  create <路径>     创建一个新的 skynet 项目
  import <模块...>   向当前目录的项目导入一个或多个模块

示例:
  skynet-creator create /path/to/new/project
  skynet-creator --force create /path/to/new/project
  skynet-creator import module1 module2 module3
EOF
}

function create_project() {
    local force="$1"
    local workdir="$2"

    echo "workdir: ${workdir}"

    if [[ "$force" == "true" ]]; then
        rm -rf "${workdir}/etc"
        rm -rf "${workdir}/make"
        rm -rf "${workdir}/service"
        rm -rf "${workdir}/lualib"
    else
        if [ -d "${workdir}" ]; then
            echo "${workdir} is already created!"
            return
        fi
    fi

    mkdir -p "${workdir}"

    cp "${RESOURCES_DIR}/templates/.gitignore" "${workdir}/"

    mkdir -p "${workdir}/lualib"
    # cp -r "${RESOURCES_DIR}/templates/lualib"/* "${workdir}/lualib/"

    mkdir -p "${workdir}/service"
    cp "${RESOURCES_DIR}/templates/service"/* "${workdir}/service/"

    mkdir -p "${workdir}/etc"
    cp "${RESOURCES_DIR}/templates/etc"/* "${workdir}/etc/"

    mkdir -p "${workdir}/make"
    cp "${RESOURCES_DIR}/templates/Makefile" "${workdir}/"
    cp "${RESOURCES_DIR}/templates/make/skynet.mk" "${workdir}/make/"

    cp "${RESOURCES_DIR}/templates/test.sh" "${workdir}/"

    cd "${workdir}"
    git init
    git branch -m master

    # skynet
    if [ ! -d "${workdir}/skynet" ]; then
        echo "add skynet: ${SKYNET_REPO}"
        git submodule add "${SKYNET_REPO}"
    fi
}

function import_modules() {
    for module in "$@"; do
        echo "导入模块: $module"
        module_script="${RESOURCES_DIR}/modules/${module}.sh"
        if [ -f "$module_script" ]; then
            RESOURCES_DIR="${RESOURCES_DIR}" bash "$module_script"
            echo "导入完成"
        else
            echo "模块导入脚本不存在: $module_script"
        fi
    done
}

# 解析命令行选项
while true; do
    case "$1" in
    -f | --force)
        force=true
        shift
        ;;
    *)
        break
        ;;
    esac
done

# 检查是否提供了足够的参数
if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

action="$1"
shift

if [[ "$action" == "create" ]]; then
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi
    create_project "$force" "$1"
elif [[ "$action" == "import" ]]; then
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi
    import_modules "$@"
else
    echo "未知操作: $action"
    exit 1
fi
