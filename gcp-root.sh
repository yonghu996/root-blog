#!/bin/bash

# 提示用户输入 SSH 端口号
read -p "请输入 SSH 端口号（默认 36275）： " SSH_PORT
SSH_PORT=${SSH_PORT:-36275}  # 如果用户未输入，则使用默认值 36275

# 检查端口号是否合法
if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || [ "$SSH_PORT" -lt 1 ] || [ "$SSH_PORT" -gt 65535 ]; then
  echo "错误：端口号必须是 1-65535 之间的数字。"
  exit 1
fi

# 备份原始配置文件
#cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 修改 SSH 配置文件
cat > /etc/ssh/sshd_config <<EOF
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

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
systemctl restart sshd

# 输出结果
echo "SSH 配置已更新："
echo "  - 端口号：$SSH_PORT"
echo "  - Root 登录已禁用"
echo "  - 公钥认证已启用"
echo "  - 密码认证已禁用"
echo "  - SSH 服务已重启"
