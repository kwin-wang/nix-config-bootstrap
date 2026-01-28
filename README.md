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
5. **交互式收集配置信息**（用户名、邮箱、SSH密钥等）
6. **自动生成配置文件**
7. 执行完整的 Nix 配置部署

## ✨ 核心特性

- 🚀 **一键部署**：单条命令完成所有设置
- 🤖 **全自动化**：自动安装依赖、配置环境
- 💬 **交互式配置**：友好的问答式收集信息
- 🔑 **1Password 集成**：安全管理 SSH 密钥和签名
- 🎨 **彩色输出**：清晰的进度提示和错误信息
- ⚙️ **智能检测**：自动检测系统架构、主机名等
- 📝 **自动生成配置**：根据输入生成 Nix 配置文件

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

### ✨ 全自动化配置

脚本会**交互式收集**你的配置信息，无需手动编辑配置文件！

**你需要准备**：
1. ✅ **1Password 账户**：确保你能登录 1Password
2. ✅ **SSH 密钥已上传到 1Password**
3. ✅ **Surge 代理配置**（可选，推荐中国用户）：准备好代理配置文件

**脚本会询问你**：
- 用户名（默认自动检测）
- 邮箱地址
- 主机名（默认自动检测）
- 是否配置 SSH 签名密钥
- 是否配置 AI 工具

所有信息收集后，脚本会自动生成配置文件并部署！

## 📋 脚本执行步骤

脚本会自动完成以下步骤：

1. **安装 Nix**（如果未安装）
   - 使用 Determinate Systems 安装器
   - 自动配置 Nix 守护进程

2. **安装 Homebrew**（如果未安装）
   - 支持 Intel 和 Apple Silicon

3. **安装 Surge**（网络代理工具，优先安装）
   - 通过 Homebrew Cask 安装
   - 提示用户配置代理
   - 避免后续步骤的网络问题

4. **安装 1Password + 1Password CLI**
   - 通过 Homebrew Cask 安装

5. **等待用户配置 1Password**
   - 提示用户登录 1Password
   - 启用 SSH Agent（Settings → Developer）
   - 验证 SSH 密钥可用

6. **克隆私密配置仓库**
   - 使用 1Password SSH Agent 认证
   - 克隆到 `~/nix-config`

7. **交互式收集配置信息**
   - 用户名（默认使用 `whoami`）
   - 邮箱地址
   - 主机名（默认使用 `hostname -s`）
   - 系统架构（自动检测 Apple Silicon 或 Intel）
   - SSH 签名密钥（可选，自动从 1Password 获取）
   - AI 工具配置（可选）

8. **自动生成配置文件**
   - 生成 `machines/<hostname>.local.nix`
   - 显示配置内容供确认
   - 支持手动修改

9. **执行完整部署**
   - 运行 `nix run nix-darwin -- switch --flake .#<hostname>`
   - 部署所有 Nix 配置

## ⚙️ 手动步骤

脚本会在以下关键点暂停，等待用户手动操作：

### 1. 配置 Surge 代理（推荐）

**适用场景**：中国网络环境，或需要代理访问 GitHub

```
⚠️  请配置 Surge 代理：
1. 打开 Surge 应用
2. 导入你的代理配置
3. 启用代理（Set as System Proxy）
4. 建议启用 Enhanced Mode 以代理所有流量
```

**为什么优先安装 Surge？**
- ✅ 避免 Nix 依赖下载失败
- ✅ 避免 Git 克隆超时
- ✅ 加速 Homebrew 包安装
- ✅ 确保后续部署顺畅

**没有 Surge？**
- 可以跳过此步骤，但可能遇到网络问题
- 或者使用其他代理工具（如 ClashX、V2rayU）

### 2. 配置 1Password SSH Agent

```
⚠️  请手动完成以下步骤：
1. 打开 1Password 应用
2. 登录你的 1Password 账户
3. 在 Settings → Developer 中勾选 "Use the SSH agent"
4. 验证密钥：运行 ssh-add -l
```

### 3. 交互式配置信息收集

脚本会逐步询问你的配置信息：

```
📝 配置信息收集
========================================

请输入用户名 [默认: your-username]:
✓ 用户名: your-username

请输入邮箱（用于 Git 配置）: user@example.com
✓ 邮箱: user@example.com

请输入主机名 [默认: MacBook-Pro]:
✓ 主机名: MacBook-Pro

✓ 系统架构: aarch64-darwin (自动检测)

可选配置：Git SSH 签名
是否配置 SSH 签名密钥? [y/N]: y
检测到以下 SSH 公钥：
  1  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...
请选择密钥编号 [1]: 1
✓ 已选择密钥

可选配置：AI 工具（Claude Code、Codex 等）
是否配置 AI 工具? [y/N]: n
```

### 4. 自动生成配置文件

脚本会根据你的输入自动生成 `machines/<hostname>.local.nix`：

```nix
{
  username = "your-username";
  useremail = "user@example.com";
  signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...";
  # ... 其他可选配置
}
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
