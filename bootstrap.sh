#!/usr/bin/env bash
set -euo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量（用户需要修改）
PRIVATE_REPO_URL="git@github.com:kwin-wang/nix-config.git"  # 修改为你的私密仓库地址
CONFIG_DIR="$HOME/nix-config"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🚀 macOS Nix 配置冷启动脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 步骤1: 检查并安装 Nix
if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}📦 Nix 未安装，开始安装...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

    echo -e "${GREEN}✓ Nix 安装完成${NC}"
    echo -e "${YELLOW}⚠️  请重新启动终端或运行以下命令加载 Nix 环境：${NC}"
    echo -e "  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    echo ""
    echo -e "${YELLOW}然后重新运行此脚本。${NC}"
    exit 0
else
    echo -e "${GREEN}✓ Nix 已安装${NC}"
fi

# 步骤2: 检查并安装 Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}📦 Homebrew 未安装，开始安装...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # 设置 Homebrew 环境变量（Apple Silicon）
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo -e "${GREEN}✓ Homebrew 安装完成${NC}"
else
    echo -e "${GREEN}✓ Homebrew 已安装${NC}"
fi

# 步骤3: 安装 1Password
if ! [ -d "/Applications/1Password.app" ]; then
    echo -e "${YELLOW}🔑 安装 1Password...${NC}"
    brew install --cask 1password
    echo -e "${GREEN}✓ 1Password 安装完成${NC}"
else
    echo -e "${GREEN}✓ 1Password 已安装${NC}"
fi

if ! command -v op &> /dev/null; then
    echo -e "${YELLOW}🔑 安装 1Password CLI...${NC}"
    brew install 1password-cli
    echo -e "${GREEN}✓ 1Password CLI 安装完成${NC}"
else
    echo -e "${GREEN}✓ 1Password CLI 已安装${NC}"
fi

# 步骤4: 等待用户配置 1Password
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}⚠️  请手动完成以下步骤：${NC}"
echo -e "${YELLOW}========================================${NC}"
echo "1. 打开 1Password 应用（已自动启动或请从 Launchpad 启动）"
echo "2. 登录你的 1Password 账户"
echo "3. 在 1Password 中启用 SSH Agent："
echo "   Settings → Developer → Use the SSH agent (勾选)"
echo "4. 验证 SSH 密钥可用："
echo "   运行: ${BLUE}ssh-add -l${NC}"
echo "   应该能看到你的 SSH 密钥列表"
echo ""

# 尝试打开 1Password
open -a "1Password" 2>/dev/null || true

read -p "$(echo -e ${GREEN}完成后按回车继续...${NC})"

# 验证 SSH Agent
echo ""
echo -e "${BLUE}🔍 验证 SSH Agent...${NC}"
if ssh-add -l &> /dev/null; then
    echo -e "${GREEN}✓ SSH Agent 已配置，密钥列表：${NC}"
    ssh-add -l
else
    echo -e "${RED}✗ SSH Agent 未正确配置${NC}"
    echo -e "${YELLOW}请确保：${NC}"
    echo "  1. 1Password 已登录"
    echo "  2. SSH Agent 已在 1Password 设置中启用"
    echo "  3. 你的 SSH 密钥已添加到 1Password"
    exit 1
fi

# 步骤5: 克隆私密配置仓库
echo ""
echo -e "${BLUE}📥 克隆私密配置仓库...${NC}"

if [ -d "$CONFIG_DIR" ]; then
    echo -e "${YELLOW}⚠️  配置目录已存在: $CONFIG_DIR${NC}"
    read -p "$(echo -e ${YELLOW}是否删除并重新克隆? [y/N]: ${NC})" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$CONFIG_DIR"
    else
        echo -e "${BLUE}使用现有配置目录${NC}"
    fi
fi

if [ ! -d "$CONFIG_DIR" ]; then
    git clone "$PRIVATE_REPO_URL" "$CONFIG_DIR"
    echo -e "${GREEN}✓ 仓库克隆完成${NC}"
fi

cd "$CONFIG_DIR/darwin"

# 步骤6: 配置 flake.local.nix
echo ""
if [ ! -f "flake.local.nix" ]; then
    echo -e "${YELLOW}⚠️  需要创建 flake.local.nix 配置文件${NC}"

    if [ -f "flake.local.nix.example" ]; then
        cp flake.local.nix.example flake.local.nix
        echo -e "${GREEN}✓ 已从示例文件创建 flake.local.nix${NC}"
    else
        echo -e "${RED}✗ 未找到 flake.local.nix.example${NC}"
    fi

    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}⚠️  请编辑配置文件：${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo "  文件路径: ${BLUE}$CONFIG_DIR/darwin/flake.local.nix${NC}"
    echo ""
    echo "  需要填写："
    echo "    - username: 你的用户名"
    echo "    - useremail: 你的邮箱"
    echo "    - hostname: 当前机器的主机名"
    echo "    - system: 系统架构 (aarch64-darwin 或 x86_64-darwin)"
    echo "    - signingkey: (可选) 1Password SSH 公钥"
    echo ""

    read -p "$(echo -e ${GREEN}编辑完成后按回车继续...${NC})"
else
    echo -e "${GREEN}✓ flake.local.nix 已存在${NC}"
fi

# 步骤7: 执行首次部署
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🎯 开始完整系统部署${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}注意：首次部署可能需要 10-30 分钟${NC}"
echo ""

read -p "$(echo -e ${GREEN}按回车开始部署...${NC})"

# 使用 nix-darwin 部署
if command -v darwin-rebuild &> /dev/null; then
    # 如果已经安装过 nix-darwin
    darwin-rebuild switch --flake .
else
    # 首次安装 nix-darwin
    nix run nix-darwin -- switch --flake .
fi

# 步骤8: 完成
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ 部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}后续管理命令（在 $CONFIG_DIR/darwin 目录下）：${NC}"
echo "  just darwin              # 应用配置更改"
echo "  just darwin-with-proxy   # 使用代理部署"
echo "  just up                  # 更新所有依赖"
echo "  just clean               # 清理旧版本"
echo ""
echo -e "${YELLOW}建议：${NC}"
echo "  1. 重新启动终端以加载所有配置"
echo "  2. 运行 'just verify-casks' 验证 Homebrew 应用"
echo ""
