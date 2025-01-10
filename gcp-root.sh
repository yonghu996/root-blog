#!/bin/bash

# 设置随机端口范围
RANDOM_PORT_MIN=10101
RANDOM_PORT_MAX=62120

# 设置用户自定义端口范围
USER_PORT_MIN=1000
USER_PORT_MAX=65000

# 函数：检查端口是否被占用
check_port_occupied() {
  local port=$1
  # 使用 ss 命令检查端口是否处于监听状态
  if ss -tuln | grep -q ":$port "; then
    return 0 # 端口被占用，返回 0
  else
    return 1 # 端口未被占用，返回 1
  fi
}

# 生成随机端口号
generate_random_port() {
  local range=$((RANDOM_PORT_MAX - RANDOM_PORT_MIN + 1))
  echo $((RANDOM % range + RANDOM_PORT_MIN))
}

# 获取默认随机端口
DEFAULT_SSH_PORT=$(generate_random_port)

# 循环直到获取到有效的且未被占用的 SSH 端口号
while true; do
  # 提示用户输入 SSH 端口号，使用默认随机端口
  read -p "请输入 SSH 端口号（默认 $DEFAULT_SSH_PORT）： " SSH_PORT
  SSH_PORT=${SSH_PORT:-$DEFAULT_SSH_PORT}  # 如果用户未输入，则使用默认随机值

  # 检查端口号是否是数字
  if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]]; then
    echo "错误：端口号必须是数字。"
    continue # 继续下一次循环
  fi

  # 检查端口号是否在允许的范围内
  if [[ "$SSH_PORT" -ge "$USER_PORT_MIN" ]] && [[ "$SSH_PORT" -le "$USER_PORT_MAX" ]]; then
    # 检查端口是否被占用
    if check_port_occupied "$SSH_PORT"; then
      echo "错误：端口 $SSH_PORT 已被占用，请更换其他端口。"
    else
      break # 端口有效且未被占用，退出循环
    fi
  else
    echo "错误：端口号必须在 $USER_PORT_MIN 到 $USER_PORT_MAX 之间。"
  fi
done

# 备份原始配置文件
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 修改 SSH 配置文件
sudo tee /etc/ssh/sshd_config > /dev/null <<EOF
# 这是 sshd 服务器的全局配置文件。 更多信息请查看 sshd_config(5)。

Include /etc/ssh/sshd_config.d/*.conf

Port $SSH_PORT
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
UsePAM no
X11Forwarding yes
PrintMotd no
ClientAliveInterval 120
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

# 重启 SSH 服务
sudo systemctl restart sshd

# 输出结果
echo "SSH 配置已更新："
echo "  - 端口号：$SSH_PORT"
echo "  - Root 登录已禁用"
echo "  - 公钥认证已启用"
echo "  - 密码认证已禁用"
echo "  - SSH 服务已重启"
