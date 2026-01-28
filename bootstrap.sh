#!/usr/bin/env bash
set -euo pipefail

# 确保交互式输入可用（支持 curl | bash 方式运行）
if [ ! -t 0 ]; then
    exec < /dev/tty
fi

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置变量
PRIVATE_REPO_URL="git@github.com:kwin-wang/nix-config.git"
CONFIG_DIR="$HOME/nix-config"
OP_SSH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# 用户配置变量（将通过交互式输入收集）
USER_NAME=""
USER_EMAIL=""
USER_HOSTNAME=""
USER_SYSTEM=""
USER_SIGNING_KEY=""
USE_AI_TOOLS=""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🚀 macOS Nix 配置冷启动脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 步骤0: 检查 Surge（在所有网络操作之前）
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}🌐 网络代理检查${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if [ -d "/Applications/Surge.app" ]; then
    echo -e "${GREEN}✓ Surge 已安装${NC}"

    # 检查是否在运行
    if pgrep -x "Surge" > /dev/null; then
        echo -e "${GREEN}✓ Surge 正在运行${NC}"
    else
        echo -e "${YELLOW}⚠️  Surge 未运行${NC}"
        read -p "$(echo -e ${BLUE}是否启动 Surge 以获得更好的网络体验? [Y/n]: ${NC})" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            open /Applications/Surge.app
            echo -e "${GREEN}✓ 已启动 Surge，等待 3 秒以确保代理生效...${NC}"
            sleep 3
        fi
    fi
else
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}⚠️  Surge 未安装${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    echo -e "${CYAN}由于后续步骤需要从网络下载大量内容，${NC}"
    echo -e "${CYAN}强烈建议先安装并配置 Surge 代理工具。${NC}"
    echo ""

    read -p "$(echo -e ${BLUE}是否自动下载并安装 Surge? [Y/n]: ${NC})" -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}🌐 开始下载 Surge...${NC}"

        # 创建临时目录
        TEMP_DIR=$(mktemp -d)
        SURGE_ZIP="$TEMP_DIR/Surge.zip"

        # 下载 Surge
        if curl -L -o "$SURGE_ZIP" "https://dl.nssurge.com/mac/v6/Surge-latest.zip"; then
            echo -e "${GREEN}✓ Surge 下载完成${NC}"

            # 解压到临时目录
            echo -e "${YELLOW}📦 解压 Surge...${NC}"
            unzip -q "$SURGE_ZIP" -d "$TEMP_DIR"

            # 移动到 Applications
            echo -e "${YELLOW}📁 安装 Surge 到 /Applications...${NC}"
            if [ -d "$TEMP_DIR/Surge.app" ]; then
                cp -R "$TEMP_DIR/Surge.app" /Applications/
                echo -e "${GREEN}✓ Surge 安装完成${NC}"

                # 清理临时文件
                rm -rf "$TEMP_DIR"

                # 打开 Surge
                echo -e "${YELLOW}🚀 启动 Surge...${NC}"
                open /Applications/Surge.app

                echo ""
                echo -e "${YELLOW}========================================${NC}"
                echo -e "${YELLOW}⚠️  请配置 Surge 代理${NC}"
                echo -e "${YELLOW}========================================${NC}"
                echo "1. Surge 已启动，请在应用中："
                echo "   - 导入你的代理配置文件"
                echo "   - 或手动配置代理规则"
                echo ""
                echo "2. 启用系统代理："
                echo "   - 点击 'Set as System Proxy'"
                echo ""
                echo "3. 建议启用 Enhanced Mode（可选）"
                echo ""
                echo -e "${CYAN}提示：首次使用需要授予 Surge 系统权限${NC}"
                echo ""

                read -p "$(echo -e ${GREEN}配置完成后按回车继续...${NC})"
                echo ""
            else
                echo -e "${RED}✗ 解压失败，未找到 Surge.app${NC}"
                rm -rf "$TEMP_DIR"
                echo -e "${YELLOW}请手动下载安装：https://nssurge.com/${NC}"
                read -p "$(echo -e ${GREEN}手动安装完成后按回车继续...${NC})"
            fi
        else
            echo -e "${RED}✗ Surge 下载失败${NC}"
            rm -rf "$TEMP_DIR"
            echo ""
            echo -e "${YELLOW}备选方案：${NC}"
            echo "1. 手动下载：https://dl.nssurge.com/mac/v6/Surge-latest.zip"
            echo "2. 访问官网：https://nssurge.com/"
            echo "3. 使用其他代理工具（ClashX、V2rayU）"
            echo ""
            read -p "$(echo -e ${GREEN}手动安装完成后按回车继续...${NC})"
        fi
    else
        echo ""
        echo -e "${YELLOW}跳过 Surge 安装${NC}"
        echo -e "${CYAN}备选方案：${NC}"
        echo "1. 使用其他代理工具（ClashX、V2rayU）"
        echo "2. 如果在海外或网络良好，可直接继续"
        echo ""
        read -p "$(echo -e ${GREEN}按回车继续...${NC})"
    fi
    echo ""
fi

# 步骤1: 检查并安装 Nix
if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}📦 Nix 未安装，开始安装（官方多用户安装）...${NC}"
    sh <(curl -L https://nixos.org/nix/install) --daemon

    echo -e "${GREEN}✓ Nix 安装完成${NC}"
    echo -e "${YELLOW}⚠️  请重新启动终端或运行以下命令加载 Nix 环境：${NC}"
    echo -e "  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
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
echo ""
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
echo "   运行: ${BLUE}SSH_AUTH_SOCK=\"\$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\" ssh-add -l${NC}"
echo "   应该能看到你的 SSH 密钥列表"
echo ""

# 尝试打开 1Password
open /Applications/1Password.app 2>/dev/null || true

read -p "$(echo -e ${GREEN}完成后按回车继续...${NC})"

# 验证 1Password SSH Agent
echo ""
echo -e "${BLUE}🔍 验证 1Password SSH Agent...${NC}"
if SSH_AUTH_SOCK="$OP_SSH_SOCK" ssh-add -l &> /dev/null; then
    echo -e "${GREEN}✓ 1Password SSH Agent 已配置，密钥列表：${NC}"
    SSH_AUTH_SOCK="$OP_SSH_SOCK" ssh-add -l
else
    echo -e "${RED}✗ 1Password SSH Agent 未正确配置${NC}"
    echo -e "${YELLOW}请确保：${NC}"
    echo "  1. 1Password 已登录"
    echo "  2. SSH Agent 已在 1Password 设置中启用"
    echo "  3. 你的 SSH 密钥已添加到 1Password"
    exit 1
fi

# 设置 SSH_AUTH_SOCK 供后续 git clone 使用
export SSH_AUTH_SOCK="$OP_SSH_SOCK"

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

# 步骤6: 收集用户配置信息
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}📝 配置信息收集${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 6.1 获取用户名
DEFAULT_USERNAME=$(whoami)
read -p "$(echo -e ${BLUE}请输入用户名 [默认: ${DEFAULT_USERNAME}]: ${NC})" USER_NAME
USER_NAME=${USER_NAME:-$DEFAULT_USERNAME}
echo -e "${GREEN}✓ 用户名: ${USER_NAME}${NC}"
echo ""

# 6.2 获取邮箱
read -p "$(echo -e ${BLUE}请输入邮箱（用于 Git 配置）: ${NC})" USER_EMAIL
while [ -z "$USER_EMAIL" ]; do
    echo -e "${RED}邮箱不能为空！${NC}"
    read -p "$(echo -e ${BLUE}请输入邮箱: ${NC})" USER_EMAIL
done
echo -e "${GREEN}✓ 邮箱: ${USER_EMAIL}${NC}"
echo ""

# 6.3 获取主机名
DEFAULT_HOSTNAME=$(hostname -s)
read -p "$(echo -e ${BLUE}请输入主机名 [默认: ${DEFAULT_HOSTNAME}]: ${NC})" USER_HOSTNAME
USER_HOSTNAME=${USER_HOSTNAME:-$DEFAULT_HOSTNAME}
echo -e "${GREEN}✓ 主机名: ${USER_HOSTNAME}${NC}"
echo ""

# 6.4 自动检测系统架构
DETECTED_ARCH=$(uname -m)
if [[ "$DETECTED_ARCH" == "arm64" ]]; then
    USER_SYSTEM="aarch64-darwin"
else
    USER_SYSTEM="x86_64-darwin"
fi
echo -e "${GREEN}✓ 系统架构: ${USER_SYSTEM} (自动检测)${NC}"
echo ""

# 6.5 询问是否配置 SSH 签名密钥
echo -e "${YELLOW}可选配置：Git SSH 签名${NC}"
echo "如果你使用 1Password SSH Agent 进行 Git commit 签名，"
echo "可以提供你的 SSH 公钥。"
echo ""
read -p "$(echo -e ${BLUE}是否配置 SSH 签名密钥? [y/N]: ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${CYAN}获取 SSH 公钥的方法：${NC}"
    echo "1. 从 1Password 复制："
    echo "   打开 1Password → SSH Keys → 复制公钥"
    echo ""
    echo "2. 从命令行查看（1Password SSH Agent）："
    echo "   SSH_AUTH_SOCK=\"\$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\" ssh-add -L"
    echo ""
    echo "3. 从本地文件读取（如果有本地密钥）："
    echo "   cat ~/.ssh/id_ed25519.pub  # 或 id_rsa.pub"
    echo ""

    # 尝试从 1Password SSH Agent 自动获取
    if SSH_AUTH_SOCK="$OP_SSH_SOCK" ssh-add -L &> /dev/null; then
        echo -e "${YELLOW}检测到以下 SSH 公钥：${NC}"
        SSH_AUTH_SOCK="$OP_SSH_SOCK" ssh-add -L | nl
        echo ""
        read -p "$(echo -e ${BLUE}请选择密钥编号 [1]: ${NC})" KEY_NUM
        KEY_NUM=${KEY_NUM:-1}
        USER_SIGNING_KEY=$(SSH_AUTH_SOCK="$OP_SSH_SOCK" ssh-add -L | sed -n "${KEY_NUM}p")
        echo -e "${GREEN}✓ 已选择密钥: ${USER_SIGNING_KEY:0:50}...${NC}"
    else
        read -p "$(echo -e ${BLUE}请粘贴 SSH 公钥: ${NC})" USER_SIGNING_KEY
    fi
    echo ""
else
    echo -e "${YELLOW}跳过 SSH 签名配置${NC}"
    echo ""
fi

# 6.6 询问是否配置 AI 工具
echo -e "${YELLOW}可选配置：AI 工具（Claude Code、Codex 等）${NC}"
read -p "$(echo -e ${BLUE}是否配置 AI 工具? [y/N]: ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    USE_AI_TOOLS="yes"
    echo -e "${YELLOW}AI 工具配置较复杂，稍后会在生成的配置文件中提供注释说明${NC}"
    echo -e "${YELLOW}你可以在部署后手动编辑 machines/${USER_HOSTNAME}.local.nix${NC}"
else
    USE_AI_TOOLS="no"
fi
echo ""

# 步骤7: 生成配置文件
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}📄 生成配置文件${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 检查机器配置文件是否存在
MACHINE_CONFIG="machines/${USER_HOSTNAME}.nix"
if [ ! -f "$MACHINE_CONFIG" ]; then
    echo -e "${YELLOW}⚠️  警告: 未找到机器配置文件 ${MACHINE_CONFIG}${NC}"
    echo -e "${YELLOW}可用的机器配置：${NC}"
    ls -1 machines/*.nix | grep -v ".local.nix" | sed 's/machines\//  - /'
    echo ""
    read -p "$(echo -e ${YELLOW}是否继续? 你可能需要稍后创建机器配置文件 [Y/n]: ${NC})" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${RED}部署已取消${NC}"
        exit 1
    fi
fi

LOCAL_CONFIG="machines/${USER_HOSTNAME}.local.nix"

# 生成配置文件内容
cat > "$LOCAL_CONFIG" << EOF
# ${USER_HOSTNAME} - 本地敏感配置
# 此文件由 bootstrap.sh 自动生成于 $(date '+%Y-%m-%d %H:%M:%S')
# 此文件已被 .gitignore 忽略，不会提交到 git

{
  # 用户名
  username = "$USER_NAME";

  # 邮箱（用于 Git 配置）
  useremail = "$USER_EMAIL";
EOF

# 添加 SSH 签名密钥（如果提供）
if [ -n "$USER_SIGNING_KEY" ]; then
    cat >> "$LOCAL_CONFIG" << EOF

  # 1Password SSH 签名密钥（用于 Git commit 签名）
  signingkey = "$USER_SIGNING_KEY";
EOF
else
    cat >> "$LOCAL_CONFIG" << EOF

  # 可选：1Password SSH 签名密钥（用于 Git commit 签名）
  # 如果你使用 1Password 作为 SSH agent 和 Git 签名，需要提供你的 SSH 公钥
  # 查看方式：
  #   ssh-add -L  # 从 1Password 查看
  #   cat ~/.ssh/id_ed25519.pub  # 从本地文件查看
  # signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...";
EOF
fi

# 添加 AI 工具配置（如果需要）
if [ "$USE_AI_TOOLS" == "yes" ]; then
    cat >> "$LOCAL_CONFIG" << 'EOF'

  # AI 工具配置（Claude Code、Codex 等）
  # 根据你的环境选择合适的配置
  aiTools = {
    # Claude 配置示例
    # claude = {
    #   # API 基础 URL
    #   # 公司环境：http://brconnector-test.sheincorp.cn
    #   # AWS Bedrock：https://bedrock-runtime.us-east-1.amazonaws.com
    #   # Anthropic API：https://api.anthropic.com
    #   baseUrl = "https://api.anthropic.com";
    #
    #   # API Token
    #   # 公司环境：sk-ant-api03-...
    #   # AWS Bedrock：留空（使用 AWS CLI 凭证）
    #   # Anthropic API：sk-ant-...
    #   authToken = "";
    #
    #   # 模型名称
    #   # 可选：claude-3-5-sonnet-20241022, claude-opus-4, shannon-auto 等
    #   model = "claude-3-5-sonnet-20241022";
    #
    #   # 是否禁用实验性功能
    #   disableExperimentalBetas = false;
    # };
    #
    # # Codex 配置示例（OpenAI 兼容接口）
    # codex = {
    #   baseUrl = "https://api.openai.com";
    #   apiKey = "sk-...";
    # };
  };
EOF
else
    cat >> "$LOCAL_CONFIG" << 'EOF'

  # 可选：AI 工具配置（Claude Code、Codex 等）
  # 如需配置，请取消注释并填写：
  # aiTools = {
  #   claude = {
  #     baseUrl = "https://api.anthropic.com";
  #     authToken = "sk-ant-...";
  #     model = "claude-3-5-sonnet-20241022";
  #   };
  # };
EOF
fi

# 添加自定义 DMG 配置
cat >> "$LOCAL_CONFIG" << 'EOF'

  # 可选：自定义应用安装（支持 DMG 和 PKG 格式）
  # 用于安装从网站下载的应用包（不在 Homebrew 中的应用）
  # customDmgs = [
  #   {
  #     name = "example-app";
  #     url = "https://example.com/app.dmg";
  #     # 可选：SHA256 校验和（推荐）
  #     # 获取方式：nix-prefetch-url <url>
  #     # sha256 = "0000000000000000000000000000000000000000000000000000";
  #   }
  # ];
}
EOF

echo -e "${GREEN}✓ 配置文件已生成: ${LOCAL_CONFIG}${NC}"
echo ""

# 显示生成的配置
echo -e "${CYAN}生成的配置内容：${NC}"
echo -e "${YELLOW}----------------------------------------${NC}"
cat "$LOCAL_CONFIG"
echo -e "${YELLOW}----------------------------------------${NC}"
echo ""

read -p "$(echo -e ${GREEN}配置正确吗? [Y/n]: ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}你可以手动编辑配置文件: ${LOCAL_CONFIG}${NC}"
    read -p "$(echo -e ${GREEN}编辑完成后按回车继续...${NC})"
fi

# 步骤8: 执行首次部署
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🎯 开始完整系统部署${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}注意：首次部署可能需要 10-30 分钟${NC}"
echo ""

read -p "$(echo -e ${GREEN}按回车开始部署...${NC})"

# 使用 nix-darwin 部署（需要 sudo 权限修改系统配置）
if command -v darwin-rebuild &> /dev/null; then
    # 如果已经安装过 nix-darwin
    sudo darwin-rebuild switch --flake ".#${USER_HOSTNAME}"
else
    # 首次安装 nix-darwin
    sudo nix run nix-darwin -- switch --flake ".#${USER_HOSTNAME}"
fi

# 步骤9: 完成
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ 部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${CYAN}配置摘要：${NC}"
echo "  用户名: ${USER_NAME}"
echo "  邮箱: ${USER_EMAIL}"
echo "  主机名: ${USER_HOSTNAME}"
echo "  系统架构: ${USER_SYSTEM}"
echo "  配置文件: ${CONFIG_DIR}/darwin/${LOCAL_CONFIG}"
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
if [ "$USE_AI_TOOLS" == "yes" ]; then
    echo "  3. 编辑 ${LOCAL_CONFIG} 完善 AI 工具配置"
fi
echo ""
