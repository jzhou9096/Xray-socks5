#这是基于F佬的脚本安装
```
bash <(wget -qO- https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh)
```
# 创建个.json文件 以root方式  
```
su -
```
```
vi /etc/sing-box/conf/20_socks_inbounds.json
```
# 复制下面
```
{
  "inbounds": [
    {
      "type": "socks",
      "tag": "my-socks5-hulu",  // 确保这个标签是唯一的
      "listen": "::",
      "listen_port": 25603,     // 您期望的 SOCKS5 端口
      "users": [
        {
          "username": "hulu",     // 您的 SOCKS5 用户名
          "password": "mfxj12356"   // 您的 SOCKS5 密码
        }
      ],
      "udp_timeout": "5m"
    }
  ]
}
```
# 按esc  
# 然后输入  
```
:wq
```
#检查整体配置语法
```
/etc/sing-box/sing-box check -C /etc/sing-box/conf
```
#重启 sing-box 服务
```
rc-service sing-box restart
rc-service sing-box status
```
#检查 sing-box 服务状态
```
rc-service sing-box status
```
