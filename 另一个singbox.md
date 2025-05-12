支持协议列表
TUIC
Trojan
Hysteria2
VMess-WS
VMess-TCP
VMess-HTTP
VMess-QUIC
Shadowsocks
VMess-H2-TLS
VMess-WS-TLS
VLESS-H2-TLS
VLESS-WS-TLS
Trojan-H2-TLS
Trojan-WS-TLS
VMess-HTTPUpgrade-TLS
VLESS-HTTPUpgrade-TLS
Trojan-HTTPUpgrade-TLS
VLESS-REALITY
VLESS-HTTP2-REALITY
Socks

安装 sing-box
输入下面命令回车，你可以复制过去，然后在 Xshell 界面按 Shift + Insert 即可粘贴，不能按 Ctrl + V 的。。
```
bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)
```
为方便你快速使用，脚本在安装完成后会自动创建一个 VLESS-REALITY 配置
此时你可以复制 URL 到相关软件 (例如 v2rayN) 去测试一下是否正常使用。

sing-box 管理面板
现在可以尝试一下输入 sb 回车，即可管理 sing-box
提示，如果你不想执行任何功能，直接按 Enter 回车退出即可。
为方便输入，脚本自动创建 sb 快捷输入命令用来代替 sb
无法使用
无法使用一般都是两种情况，一是无法连接上端口，二是客户端内核支持有问题。

如果你的 VPS 有外部防火墙，请确保你已经开放了端口

测试端口是否能连接上：

打开：https://tcp.ping.pe/

写上你的 VPS IP 跟端口；内容为 ip:端口，示例：1.1.1.1:443，然后点击 Go；或者直接回车

如果显示 successful；证明端口能连接；如果显示 failed；那是无法连接上端口。

提醒，你可以使用 sb ip 查看 VPS IP。

关闭防火墙，执行如下命令：
```
systemctl stop firewalld; systemctl disable firewalld; ufw disable
```
关闭防火墙之后再测试一下端口是否通，如果不通，你可能还有外部防火墙没关，必须要能连接上端口才能正常使用。

如果能连接上端口，那就继续

使用 
```
sb add ss auto auto aes-256-gcm
```
添加一个 SS 看看能不能正常使用，如果正常使用，证明运行没有问题。

提醒，默认安装的 sing-box 内核为最新版本

如果无法使用，可能是你客户端的内核太旧

请尝试使用不同的客户端进行测试；比如 v2rayN；v2rayNG 等

请尝试设置 VMessAEAD，某些客户端会有相关选项

某些客户端得把 额外id(alterid) 填写为 0；比如垃圾苹果那边的东西

请更新你的客户端 sing-box 内核跟服务器端版本保持一致！
快速入门
本人的 sing-box 脚本简化了很多流程，例如我们常用的是 (添加、更改、查看、删除) 配置，以下内容让你可以快速掌握使用

添加配置：

sb add -> 添加配置

sb add reality -> 添加一个 VLESS-REALITY 配置

sb add reality 443 auto dl.google.com -> 同上，自定义参数：端口使用 443， SNI 使用 dl.google.com

sb add hy -> 添加一个 Hysteria2 配置

sb add ss -> 添加一个 Shadowsocks 2022 配置

sb add tcp -> 添加一个 VMess-TCP 配置

sb add tuic -> 添加一个 TUIC配置

备注，使用 sb add 添加配置的时候，仅 *TLS 相关协议配置必须提供域名，其他均可自动化处理。

如需查看更多 add 参数用法，请查看下面的 sing-box 脚本说明

–

更改配置：

sb change -> 更改配置

sb change reality -> 更改 REALITY 相关配置

sb change reality sni 1.1.1.1 -> 更改 REALITY 相关配置的 SNI 为 1.1.1.1, 也可以使用 sb sni reality 1.1.1.1

sb change tcp -> 更改 TCP 相关配置

sb change tcp port auto -> 更改 TCP 相关配置的端口，端口使用自动创建，也可以使用 sb port tcp auto

sb change tuic id auto -> 更改 tuic 相关配置的 UUID，UUID 使用自动创建，也可以使用 sb id tuic auto

如需查看更多 change 参数用法，请查看下面的 sing-box 脚本说明

–

查看配置：

sb info -> 查看配置

sb info REALITY -> 查看 REALITY 相关配置

sb info tcp -> 查看 TCP 相关配置

–

删除配置：

sb del -> 删除配置

sb del REALITY -> 删除 REALITY 相关配置

sb del tcp -> 删除 TCP 相关配置
