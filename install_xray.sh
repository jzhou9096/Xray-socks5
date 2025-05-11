#!/bin/bash

# --- 配置开始 (您可以从环境变量或脚本参数获取这些值) ---
XRAY_USER_DEFAULT="hulu"
XRAY_PASS_DEFAULT="hulu123"
XRAY_PORT_DEFAULT="25603"

# 从环境变量读取，如果未设置则使用默认值
XRAY_USER="${XRAY_USER_ENV:-$XRAY_USER_DEFAULT}"
XRAY_PASS="${XRAY_PASS_ENV:-$XRAY_PASS_DEFAULT}"
XRAY_PORT="${XRAY_PORT_ENV:-$XRAY_PORT_DEFAULT}"

# GitHub 仓库中配置文件的原始链接 (确保是 Raw 链接)
# 请将 YOUR_USERNAME 和 YOUR_REPO_NAME 替换为您实际的 GitHub 用户名和仓库名
# 例如: jzhou9096 和 Xray-socks5
# 假设您的主分支是 main
GITHUB_USERNAME="jzhou9096"
GITHUB_REPO="Xray-socks5"
GITHUB_BRANCH="main" # 或者您的主分支名，例如 master

CONFIG_TEMPLATE_URL="https://raw.githubusercontent.com/${GITHUB_USERNAME}/${GITHUB_REPO}/${GITHUB_BRANCH}/config_template.json"
OPENRC_SCRIPT_URL="https://raw.githubusercontent.com/${GITHUB_USERNAME}/${GITHUB_REPO}/${GITHUB_BRANCH}/xray_openrc_script"
# --- 配置结束 ---

echo ">>> 开始安装 Xray SOCKS5 代理 <<<"
echo "使用配置: 用户=${XRAY_USER}, 端口=${XRAY_PORT}"

# 0. 更新系统并安装必要工具
echo ">>> 步骤 0: 更新系统并安装必要工具 (curl, unzip)..."
if ! apk info curl >/dev/null 2>&1 || ! apk info unzip >/dev/null 2>&1; then
    sudo apk update
fi
if ! apk info curl >/dev/null 2>&1; then
    sudo apk add curl
fi
if ! apk info unzip >/dev/null 2>&1; then
    sudo apk add unzip
fi


# 1. 下载并安装 Xray 核心
echo ">>> 步骤 1: 下载并安装 Xray 核心..."
CPU_ARCH=$(uname -m)
XRAY_VERSION_LATEST=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$XRAY_VERSION_LATEST" ]; then
    echo "错误：无法获取最新的 Xray 版本号。请检查网络或GitHub API访问。"
    exit 1
fi
echo "最新的 Xray 版本: $XRAY_VERSION_LATEST"

XRAY_FILENAME=""
if [ "$CPU_ARCH" = "x86_64" ]; then
    XRAY_FILENAME="Xray-linux-64.zip"
elif [ "$CPU_ARCH" = "aarch64" ]; then
    XRAY_FILENAME="Xray-linux-arm64-v8a.zip"
# 您可以根据需要为其他架构添加 elif 条件
# elif [ "$CPU_ARCH" = "armv7l" ]; then
#     XRAY_FILENAME="Xray-linux-arm32-v7a.zip"
else
    echo "错误：不支持的 CPU 架构: $CPU_ARCH"
    exit 1
fi

DOWNLOAD_URL="https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION_LATEST}/${XRAY_FILENAME}"
echo "正在从 $DOWNLOAD_URL 下载 Xray..."
curl -L -o xray.zip "$DOWNLOAD_URL"
if [ $? -ne 0 ]; then
    echo "错误：下载 Xray (${XRAY_FILENAME}) 失败。"
    exit 1
fi

echo "正在解压 Xray..."
sudo mkdir -p /usr/local/bin/
sudo mkdir -p /usr/local/share/xray/ # assetsdir
sudo unzip -o xray.zip xray -d /usr/local/bin/
if [ $? -ne 0 ]; then
    echo "错误：解压 xray 可执行文件失败。"
    rm xray.zip
    exit 1
fi
sudo chmod +x /usr/local/bin/xray

# 尝试解压 geoip.dat 和 geosite.dat (如果它们在压缩包中)
if unzip -l xray.zip 2>/dev/null | grep -q geoip.dat; then
    sudo unzip -o xray.zip geoip.dat -d /usr/local/share/xray/
    echo "geoip.dat 已解压。"
else
    echo "提示：压缩包中未直接找到 geoip.dat。Xray 可能会尝试自行下载/更新，或者您可以从 https://github.com/Loyalsoldier/v2ray-rules-dat 手动下载到 /usr/local/share/xray/"
fi
if unzip -l xray.zip 2>/dev/null | grep -q geosite.dat; then
    sudo unzip -o xray.zip geosite.dat -d /usr/local/share/xray/
    echo "geosite.dat 已解压。"
else
    echo "提示：压缩包中未直接找到 geosite.dat。Xray 可能会尝试自行下载/更新，或者您可以从 https://github.com/Loyalsoldier/v2ray-rules-dat 手动下载到 /usr/local/share/xray/"
fi

rm xray.zip
echo "Xray 核心安装完成。"

# 2. 创建配置文件目录并下载/生成配置文件
echo ">>> 步骤 2: 创建配置文件..."
sudo mkdir -p /usr/local/etc/xray/
CONFIG_PATH="/usr/local/etc/xray/config.json"
TEMP_CONFIG_DOWNLOAD_PATH="./temp_config_download.json" # 下载到当前目录临时文件

echo "正在从 $CONFIG_TEMPLATE_URL 下载配置文件模板..."
curl -L -o "$TEMP_CONFIG_DOWNLOAD_PATH" "$CONFIG_TEMPLATE_URL"
if [ $? -ne 0 ]; then
    echo "错误：下载配置文件模板失败。请检查URL和网络。"
    exit 1
fi

echo "正在替换配置占位符..."
# 使用 sed 替换占位符
# 注意 Alpine Linux 的 sed (BusyBox sed) 可能与 GNU sed 行为略有不同，但基本替换应该没问题。
# 为了安全起见，先处理特殊字符，虽然这里的占位符和替换内容比较简单。
ESCAPED_XRAY_USER=$(echo "$XRAY_USER" | sed 's/[\/&]/\\&/g')
ESCAPED_XRAY_PASS=$(echo "$XRAY_PASS" | sed 's/[\/&]/\\&/g')
ESCAPED_XRAY_PORT=$(echo "$XRAY_PORT" | sed 's/[\/&]/\\&/g')

PROCESSED_CONFIG_PATH="./processed_config.json"
sed -e "s/__XRAY_USER__/$ESCAPED_XRAY_USER/g" \
    -e "s/__XRAY_PASS__/$ESCAPED_XRAY_PASS/g" \
    -e "s/__XRAY_PORT__/$ESCAPED_XRAY_PORT/g" \
    "$TEMP_CONFIG_DOWNLOAD_PATH" > "$PROCESSED_CONFIG_PATH"

if [ $? -ne 0 ]; then
    echo "错误：替换配置文件占位符失败。"
    rm "$TEMP_CONFIG_DOWNLOAD_PATH"
    exit 1
fi

sudo mv "$PROCESSED_CONFIG_PATH" "$CONFIG_PATH"
rm "$TEMP_CONFIG_DOWNLOAD_PATH"
echo "配置文件 $CONFIG_PATH 已创建。"

# 3. 创建 OpenRC 服务脚本
echo ">>> 步骤 3: 创建 OpenRC 服务脚本..."
OPENRC_SCRIPT_PATH="/etc/init.d/xray"
TEMP_OPENRC_DOWNLOAD_PATH="./temp_openrc_download.sh"

echo "正在从 $OPENRC_SCRIPT_URL 下载 OpenRC 脚本..."
curl -L -o "$TEMP_OPENRC_DOWNLOAD_PATH" "$OPENRC_SCRIPT_URL"
if [ $? -ne 0 ]; then
    echo "错误：下载 OpenRC 脚本失败。请检查URL和网络。"
    exit 1
fi
sudo mv "$TEMP_OPENRC_DOWNLOAD_PATH" "$OPENRC_SCRIPT_PATH"
sudo chmod +x "$OPENRC_SCRIPT_PATH"
echo "OpenRC 服务脚本 $OPENRC_SCRIPT_PATH 已创建。"

# 4. 启动并设置 Xray 开机自启
echo ">>> 步骤 4: 启动并设置 Xray 开机自启..."
echo "正在尝试重启 Xray 服务 (如果之前已存在)..."
if rc-service -e xray; then # 检查服务是否存在
    sudo rc-service xray stop > /dev/null 2>&1 # 尝试停止，忽略错误
fi
sudo rc-service xray start
if [ $? -ne 0 ]; then
    echo "错误：启动 Xray 服务失败。请运行 'sudo /usr/local/bin/xray -config /usr/local/etc/xray/config.json -test' 进行检查，并查看日志。"
    exit 1
fi
sudo rc-update add xray default
echo "Xray 服务已启动并设置为开机自启。"

echo ""
echo ">>> Xray SOCKS5 代理安装和配置完成! <<<"
echo "服务器信息:"
echo "  协议: SOCKS5"
echo "  地址: (您的 VPS IPv6 地址)"
echo "  端口: $XRAY_PORT"
echo "  用户: $XRAY_USER"
echo "  密码: $XRAY_PASS"
echo ""
echo "请确保您的防火墙允许 IPv6 流量访问 TCP 和 UDP 端口 $XRAY_PORT。"
