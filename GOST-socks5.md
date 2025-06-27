
### 【GOST SOCKS5 代理服务完整备忘录】

#### 第 1 部分：一键安装 GOST (首次配置或重装系统时使用)

```bash
# 安装依赖工具
apk add wget tar

# 下载 GOST
wget https://github.com/go-gost/gost/releases/download/v3.0.0-rc8/gost_3.0.0-rc8_linux_amd64.tar.gz

# 解压
tar -zxvf gost_3.0.0-rc8_linux_amd64.tar.gz

# 将 gost 程序移动到系统路径中
mv gost /usr/local/bin/

# 赋予可执行权限
chmod +x /usr/local/bin/gost

# (可选) 清理安装文件
rm -f gost_3.0.0-rc8_linux_amd64.tar.gz
```

-----

#### 第 2 部分：启动 SOCKS5 代理服务

这是你以后重启 VPS 或重启服务时最常用的命令。

```bash
nohup gost -L=socks5://hulu:mfxj12356@:36582 >/dev/null 2>&1 &
```

**参数说明 (方便你以后修改):**

  * `hulu`：是你的用户名
  * `mfxj12356`：是你的密码
  * `36582`：是你的服务端口

-----

#### 第 3 部分：日常管理与检查

**1. 检查服务是否正在运行 (最常用)**
这个命令可以让你看到进程，并能回忆起你设置的用户名、密码和端口。

```bash
ps aux | grep gost
```

**2. 检查端口是否在监听**

```bash
netstat -tulnp | grep 36582
```

**3. 停止服务**

```bash
pkill gost
```

**4. 重启服务**
很简单，分两步：

1.  先用 `pkill gost` 停止。
2.  再运行第 2 部分的 `nohup` 命令来启动。

-----

