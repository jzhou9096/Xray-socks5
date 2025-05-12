#更改端口，用户名等信息
```
apk update
apk add jq
```
#下面全选
# --- 开始修改 Xray 配置 ---
```
# 1. 定义您想要设置的新参数
NEW_PORT=36583
NEW_USER="faguoxiaoji"
NEW_PASS="faguochat123"
CONFIG_FILE="/usr/local/etc/xray/config.json"
TEMP_CONFIG_FILE="${CONFIG_FILE}.tmp" # 临时文件名

# 2. 备份当前的配置文件 (可选但推荐，以防万一)
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak_$(date +%Y%m%d_%H%M%S)"
echo "当前配置文件已备份。"
# 3. 使用 jq 修改配置
#    这个命令会读取原始配置文件，进行修改，然后将结果输出到临时文件
echo "正在使用 jq 修改配置文件..."
jq \
  --argjson new_port "$NEW_PORT" \
  --arg new_user "$NEW_USER" \
  --arg new_pass "$NEW_PASS" \
  '.inbounds[0].port = $new_port | .inbounds[0].settings.accounts[0].user = $new_user | .inbounds[0].settings.accounts[0].pass = $new_pass' \
  "$CONFIG_FILE" > "$TEMP_CONFIG_FILE"

# 4. 检查 jq 命令是否成功执行以及临时文件是否有效
if [ $? -eq 0 ] && [ -s "$TEMP_CONFIG_FILE" ]; then
    # 如果成功，用修改后的临时文件替换原始配置文件
    mv "$TEMP_CONFIG_FILE" "$CONFIG_FILE"
    echo "配置文件已成功更新为："
    echo "  端口: $NEW_PORT"
    echo "  用户: $NEW_USER"
    # (密码不会直接显示出来)

    # 5. 重启 Xray 服务使新配置生效
    echo "正在重启 Xray 服务..."
    rc-service xray restart
    
    # 6. 检查 Xray 服务状态
    sleep 2 # 等待服务有时间启动
    rc-service xray status
    if rc-service xray status | grep -q "started"; then
        echo "Xray 服务已成功重启并运行。"
    else
        echo "错误：Xray 服务未能成功启动。请检查日志或配置。"
        echo "您可以尝试使用以下命令测试配置："
        echo "/usr/local/bin/xray -config /usr/local/etc/xray/config.json -test"
        echo "如果配置有误，您可以从备份恢复： cp ${CONFIG_FILE}.bak_$(date +%Y%m%d_%H%M%S) ${CONFIG_FILE} (请注意备份文件名的时间戳)"
    fi
else
    echo "错误：使用 jq 修改配置文件失败，或者生成的临时文件为空。"
    echo "原始配置文件未被修改。"
    # 删除可能不正确的临时文件
    if [ -f "$TEMP_CONFIG_FILE" ]; then
        rm "$TEMP_CONFIG_FILE"
    fi
fi

# --- Xray 配置修改结束 ---
```
