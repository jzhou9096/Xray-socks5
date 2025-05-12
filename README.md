# 安装xray-socks5
# 一键安装
```
curl -L "https://raw.githubusercontent.com/jzhou9096/Xray-socks5/main/install_xray.sh" | sudo bash
```
# 或
```
curl -L "https://raw.githubusercontent.com/jzhou9096/Xray-socks5/main/install_xray.sh" -o install_xray.sh

chmod +x install_xray.sh

./install_xray.sh
```
# 安装步骤
# 获取 install_xray.sh 脚本的 Raw 链接
```
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/jzhou9096/Xray-socks5/main/install_xray.sh"
```
# 下载脚本
```
curl -L "$INSTALL_SCRIPT_URL" -o install_xray.sh
```
# 赋予执行权限
chmod +x install_xray.sh

# 执行脚本 (使用默认配置)
```
sudo ./install_xray.sh
```
# 或者，如果您想使用自定义的用户名、密码和端口，可以通过环境变量传递：
# sudo XRAY_USER_ENV="用户名" XRAY_PASS_ENV="密码" XRAY_PORT_ENV="端口" ./install_xray.sh
