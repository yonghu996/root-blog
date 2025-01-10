# 个人自用脚本库
  ·主要用于修改gcp、普通机子的ssh登录端口、密码
## gcp-root.sh
### gcp的一键修改的脚本：gcp-root.sh
  一键修改ssh_config配置内容：
  - 端口号：自定义(默认为随机端口)
  - Root 登录已禁用
  - 公钥认证已启用
  - 密码认证已禁用
  - SSH 服务已重启
  ·一键拉取命令
  ```
  sudo wget -N --no-check-certificate https://raw.githubusercontent.com/yonghu996/root-blog/main/gcp-root.sh && bash gcp-root.sh
  ```
