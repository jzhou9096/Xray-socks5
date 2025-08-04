# 1、安装docker
```
curl -fsSL https://get.docker.com -o get-docker.sh
```
```
sudo sh get-docker.sh
```
# 2、安装xdd
Debian：
```
apt-get install xxd
```
# 3、拉取镜像
```
docker pull ellermister/nginx-mtproxy:latest
```
# 4、自定义安装
- 获取secret
```
secret=$(head -c 16 /dev/urandom | xxd -ps)
```
- 查看secret
```
echo $secret
```
- 从 https://t.me/MTProxybot 获取tag
```
tag="3bb86bf4dced2a42c65a9f17e664eb"
```
# 添加伪装
```
domain="cloudflare.com"
```
# 部署nginx-mtproxy 添加TAG
```
docker run --name nginx-mtproxy -d -e tag="$tag" -e secret="$secret" -e domain="$domain" -e ip_white_list="OFF" -p 8080:80 -p 8443:443 ellermister/nginx-mtproxy:latest
```
# 部署nginx-mtproxy不添加TAG
```
docker run --name n-mt -d -e secret="$secret" -e domain="$domain" -e ip_white_list="OFF" -p 8081:80 -p 35681:443 ellermister/nginx-mtproxy:latest
```
# 部署nginx-mtproxy添加白名单不添加TAG
```
docker run --name n-mt -d -e secret="$secret" -e domain="$domain" -e ip_white_list="IP" -p 8081:80 -p 8443:443 ellermister/nginx-mtproxy:latest
```
# ip_white_list 可选参数为:

- IP 允许单个 IP 访问

- IPSEG 允许 IP 段访问

- OFF 允许所有 IP 访问

- -p端口可自定义

http://ip/add.php

# 查看：
```
docker logs n-mt
```
源文件：https://hub.docker.com/r/ellermister/nginx-mtproxy
