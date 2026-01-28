# macOS Nix 配置引导仓库

这是一个**公开的引导仓库**，用于在全新 macOS 系统上自动化部署你的私密 Nix 配置。

## 🎯 解决的问题

在全新系统上部署 Nix 配置时会遇到**循环依赖问题**：

```
需要克隆私密仓库 → 需要 SSH 密钥 → 密钥在 1Password →
1Password 需要 Nix 配置部署 → 需要克隆仓库... 死循环
```

**本仓库的解决方案**：
1. 自动安装 Nix 和 Homebrew
2. 安装 1Password（用于访问 SSH 密钥）
3. 配置 SSH Agent
4. 克隆你的私密配置仓库
5. 执行完整的 Nix 配置部署

## 🚀 快速开始

### 一键部署

在全新 macOS 系统上运行：

```bash
curl -fsSL https://raw.githubusercontent.com/kwin-wang/nix-config-bootstrap/main/bootstrap.sh | bash
```

**或者**手动下载执行：

```bash
# 克隆本仓库（无需认证，公开仓库）
git clone https://github.com/kwin-wang/nix-config-bootstrap.git
cd nix-config-bootstrap

# 执行引导脚本
./bootstrap.sh
```

### 配置前准备

在运行脚本前，你需要：

1. ✅ **1Password 账户**：确保你能登录 1Password
2. ✅ **SSH 密钥已上传到 1Password**
3. ✅ **私密仓库地址**：修改 `bootstrap.sh` 中的 `PRIVATE_REPO_URL`

编辑 `bootstrap.sh` 第 12 行：

```bash
PRIVATE_REPO_URL="git@github.com:kwin-wang/nix-config.git"  # 改为你的仓库
```

## 📋 脚本执行步骤

脚本会自动完成以下步骤：

1. **安装 Nix**（如果未安装）
   - 使用 Determinate Systems 安装器
   - 自动配置 Nix 守护进程

2. **安装 Homebrew**（如果未安装）
   - 支持 Intel 和 Apple Silicon

3. **安装 1Password + 1Password CLI**
   - 通过 Homebrew Cask 安装

4. **等待用户配置 1Password**
   - 提示用户登录 1Password
   - 启用 SSH Agent（Settings → Developer）
   - 验证 SSH 密钥可用

5. **克隆私密配置仓库**
   - 使用 1Password SSH Agent 认证
   - 克隆到 `~/nix-config`

6. **配置 flake.local.nix**
   - 从示例文件创建
   - 提示用户填写个人信息

7. **执行完整部署**
   - 运行 `nix run nix-darwin -- switch --flake .`
   - 部署所有 Nix 配置

## ⚙️ 手动步骤

脚本会在以下关键点暂停，等待用户手动操作：

### 1. 配置 1Password SSH Agent

```
⚠️  请手动完成以下步骤：
1. 打开 1Password 应用
2. 登录你的 1Password 账户
3. 在 Settings → Developer 中勾选 "Use the SSH agent"
4. 验证密钥：运行 ssh-add -l
```

### 2. 编辑 flake.local.nix

```
⚠️  请编辑配置文件：
  文件路径: ~/nix-config/darwin/flake.local.nix

  需要填写：
    - username: 你的用户名
    - useremail: 你的邮箱
    - hostname: 当前机器的主机名
    - system: 系统架构 (aarch64-darwin 或 x86_64-darwin)
    - signingkey: (可选) 1Password SSH 公钥
```

## 🔧 自定义配置

### 修改私密仓库地址

编辑 `bootstrap.sh`：

```bash
PRIVATE_REPO_URL="git@github.com:YOUR_USERNAME/nix-config.git"
CONFIG_DIR="$HOME/nix-config"  # 可选：修改安装目录
```

### 跳过已安装的工具

脚本会自动检测已安装的工具（Nix、Homebrew、1Password），跳过重复安装。

## 🐛 故障排除

### Nix 安装后命令找不到

需要重新加载环境：

```bash
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

或重启终端后重新运行脚本。

### SSH Agent 验证失败

确保：
1. 1Password 已登录
2. SSH Agent 已在 1Password 设置中启用
3. SSH 密钥已添加到 1Password（类型为 SSH Key）

验证命令：

```bash
ssh-add -l  # 应该显示密钥列表
```

### Git 克隆失败

检查：
1. `PRIVATE_REPO_URL` 是否正确
2. SSH 密钥是否有仓库访问权限
3. 网络连接是否正常

手动测试：

```bash
ssh -T git@github.com  # 应该显示认证成功
```

### 首次部署时间过长

首次部署需要下载大量依赖，可能需要 10-30 分钟，这是正常现象。

如果在中国网络环境，可以在部署后使用代理：

```bash
cd ~/nix-config/darwin
just darwin-with-proxy
```

## 📚 相关文档

- [私密配置仓库](https://github.com/kwin-wang/nix-config)
- [Nix 官方文档](https://nixos.org/manual/nix/stable/)
- [nix-darwin 文档](https://github.com/LnL7/nix-darwin)
- [1Password SSH Agent 文档](https://developer.1password.com/docs/ssh/)

## 🔒 安全说明

- ✅ 本仓库**不包含**任何敏感信息
- ✅ 所有密钥和配置都在你的私密仓库中
- ✅ 1Password 用于安全管理 SSH 密钥
- ✅ 脚本可以安全公开

## 📝 更新日志

### v1.0.0 (2026-01-28)

- 初始版本
- 支持自动安装 Nix、Homebrew、1Password
- 自动克隆私密配置仓库
- 自动执行首次部署

## 🤝 贡献

本仓库是个人引导仓库模板，你可以 fork 后修改为自己的配置。

## 📄 许可证

MIT License
