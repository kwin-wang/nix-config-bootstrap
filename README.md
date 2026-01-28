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
- 🌐 **自动安装代理**：检测并自动下载安装 Surge（解决网络问题）
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
1. ✅ **网络代理**（强烈推荐，中国用户必需）：
   - 提前安装并配置 Surge、ClashX 或 V2rayU
   - 在运行脚本前启动代理
   - 避免 Nix、Homebrew 安装失败
2. ✅ **1Password 账户**：确保你能登录 1Password
3. ✅ **SSH 密钥已上传到 1Password**

**脚本会询问你**：
- 用户名（默认自动检测）
- 邮箱地址
- 主机名（默认自动检测）
- 是否配置 SSH 签名密钥
- 是否配置 AI 工具

所有信息收集后，脚本会自动生成配置文件并部署！

## 📋 脚本执行步骤

脚本会自动完成以下步骤：

0. **网络代理自动安装**（⭐ 最重要）
   - 检查 Surge 是否已安装并运行
   - 如未安装，询问是否自动下载安装
   - 自动下载：https://dl.nssurge.com/mac/v6/Surge-latest.zip
   - 自动解压并安装到 /Applications
   - 自动启动并引导用户配置

1. **安装 Nix**（如果未安装）
   - 使用 Determinate Systems 安装器
   - 自动配置 Nix 守护进程
   - **需要网络连接**

2. **安装 Homebrew**（如果未安装）
   - 支持 Intel 和 Apple Silicon
   - **需要网络连接**

3. **安装 1Password + 1Password CLI**
   - 通过 Homebrew Cask 安装

4. **等待用户配置 1Password**
   - 提示用户登录 1Password
   - 启用 SSH Agent（Settings → Developer）
   - 验证 SSH 密钥可用

5. **克隆私密配置仓库**
   - 使用 1Password SSH Agent 认证
   - 克隆到 `~/nix-config`
   - **需要网络连接**

6. **交互式收集配置信息**
   - 用户名（默认使用 `whoami`）
   - 邮箱地址
   - 主机名（默认使用 `hostname -s`）
   - 系统架构（自动检测 Apple Silicon 或 Intel）
   - SSH 签名密钥（可选，自动从 1Password 获取）
   - AI 工具配置（可选）

7. **自动生成配置文件**
   - 生成 `machines/<hostname>.local.nix`
   - 显示配置内容供确认
   - 支持手动修改

8. **执行完整部署**
   - 运行 `nix run nix-darwin -- switch --flake .#<hostname>`
   - 部署所有 Nix 配置
   - **需要网络连接**

## ⚙️ 手动步骤

脚本会在以下关键点暂停，等待用户手动操作：

### 0. 网络代理安装（⭐ 自动化）

**脚本会自动检测并安装 Surge**：

```
🌐 网络代理检查
========================================

⚠️  Surge 未安装

由于后续步骤需要从网络下载大量内容，
强烈建议先安装并配置 Surge 代理工具。

是否自动下载并安装 Surge? [Y/n]: y

🌐 开始下载 Surge...
✓ Surge 下载完成
📦 解压 Surge...
📁 安装 Surge 到 /Applications...
✓ Surge 安装完成
🚀 启动 Surge...

⚠️  请配置 Surge 代理
1. Surge 已启动，请在应用中：
   - 导入你的代理配置文件
   - 或手动配置代理规则

2. 启用系统代理：
   - 点击 'Set as System Proxy'

3. 建议启用 Enhanced Mode（可选）

提示：首次使用需要授予 Surge 系统权限

配置完成后按回车继续...
```

**自动化特性**：
- ✅ 自动下载最新版 Surge
- ✅ 自动解压并安装
- ✅ 自动启动应用
- ✅ 引导用户配置

**下载失败时的备选方案**：
1. 手动下载：https://dl.nssurge.com/mac/v6/Surge-latest.zip
2. 访问官网：https://nssurge.com/
3. 使用其他代理工具（ClashX、V2rayU）

**为什么需要代理？**

脚本需要从网络下载：
- Nix 安装器和依赖包
- Homebrew 安装脚本
- Git 克隆私密仓库
- Nix 包和 Homebrew 软件

**没有代理的后果（中国网络环境）**：
- ❌ Nix 安装失败或超时
- ❌ Homebrew 安装失败
- ❌ Git 克隆超时
- ❌ 部署过程中断

### 1. 配置 1Password SSH Agent

```
⚠️  请手动完成以下步骤：
1. 打开 1Password 应用
2. 登录你的 1Password 账户
3. 在 Settings → Developer 中勾选 "Use the SSH agent"
4. 验证密钥：运行 ssh-add -l
```

### 2. 交互式配置信息收集

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

### 3. 自动生成配置文件

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
