#!/bin/bash

# ============================================================================
# CCPM Enhanced - Smart Installation Script
# 智能安装脚本 - 处理各种边界情况
# 
# 功能：安全、智能地安装CCPM Enhanced到当前目录
# 作者：CCPM Enhanced Project
# ============================================================================

set -e  # 遇到错误立即退出

# 全局变量
REPO_URL="https://github.com/zack744/CCPM-DIY.git"
SCRIPT_VERSION="1.0.0"
INSTALL_DIR="."
BACKUP_DIR=""
ERROR_COUNT=0

# 颜色定义（跨平台兼容）
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows环境，使用简单输出
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    CYAN=""
    NC=""
else
    # Unix环境，使用颜色
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
fi

# ============================================================================
# 日志输出函数
# ============================================================================

log_info() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1"
    ((ERROR_COUNT++))
}

log_step() {
    echo -e "${BLUE}🔍${NC} $1"
}

log_success() {
    echo -e "${GREEN}🎉${NC} $1"
}

# ============================================================================
# 清理和错误处理函数
# ============================================================================

cleanup() {
    log_step "清理临时文件..."
    
    # 清理可能的临时文件
    [ -d ".git" ] && rm -rf .git 2>/dev/null || true
    [ -f "install.tmp" ] && rm -f install.tmp 2>/dev/null || true
    
    # 如果安装失败，恢复备份
    if [ $ERROR_COUNT -gt 0 ] && [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        log_warning "安装失败，恢复备份文件..."
        restore_backup
    fi
}

# 设置错误处理
trap 'log_error "安装被中断"; cleanup; exit 1' INT TERM
trap 'if [ $? -ne 0 ]; then log_error "安装过程出错"; cleanup; fi' EXIT

create_backup() {
    if [ "$(ls -A . 2>/dev/null)" ]; then
        BACKUP_DIR=".ccpm-backup-$(date +%Y%m%d_%H%M%S)"
        log_step "创建备份: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        
        # 备份关键文件
        for item in *; do
            if [ "$item" != "$BACKUP_DIR" ]; then
                cp -r "$item" "$BACKUP_DIR/" 2>/dev/null || true
            fi
        done
        
        log_info "备份完成: $BACKUP_DIR"
        return 0
    fi
    return 1
}

restore_backup() {
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        log_step "恢复备份文件..."
        # 清理失败的安装
        for item in *; do
            if [ "$item" != "$BACKUP_DIR" ]; then
                rm -rf "$item" 2>/dev/null || true
            fi
        done
        # 恢复备份
        cp -r "$BACKUP_DIR"/* . 2>/dev/null || true
        rm -rf "$BACKUP_DIR"
        log_info "备份已恢复"
    fi
}

# ============================================================================
# 环境检测函数
# ============================================================================

check_git() {
    log_step "检查Git环境..."
    
    if ! command -v git >/dev/null 2>&1; then
        log_error "未找到Git命令"
        echo ""
        echo "请先安装Git："
        echo "  Windows: https://git-scm.com/downloads"
        echo "  macOS:   brew install git"
        echo "  Ubuntu:  sudo apt install git"
        return 1
    fi
    
    # 检查Git版本
    local git_version
    git_version=$(git --version | grep -o '[0-9]\+\.[0-9]\+' | head -1)
    log_info "Git版本: $git_version"
    
    return 0
}

check_network() {
    log_step "检查网络连接..."
    
    # 测试GitHub连接
    if ! git ls-remote --exit-code "$REPO_URL" >/dev/null 2>&1; then
        log_error "无法连接到仓库: $REPO_URL"
        echo ""
        echo "可能的解决方案："
        echo "  1. 检查网络连接"
        echo "  2. 使用VPN或代理"
        echo "  3. 使用镜像地址"
        return 1
    fi
    
    log_info "网络连接正常"
    return 0
}

check_permissions() {
    log_step "检查目录权限..."
    
    if [ ! -w . ]; then
        log_error "当前目录没有写权限"
        echo "请检查目录权限或切换到其他目录"
        return 1
    fi
    
    log_info "目录权限正常"
    return 0
}

check_disk_space() {
    log_step "检查磁盘空间..."
    
    # 检查可用空间（需要至少20MB）
    if command -v df >/dev/null 2>&1; then
        local available_kb
        available_kb=$(df . | tail -1 | awk '{print $4}')
        
        if [ "$available_kb" -lt 20480 ]; then  # 20MB
            log_warning "磁盘空间不足，可能影响安装"
        else
            log_info "磁盘空间充足"
        fi
    fi
    
    return 0
}

# ============================================================================
# 安装状态检测
# ============================================================================

detect_existing_installation() {
    log_step "检测现有安装..."
    
    if [ -d ".claude" ]; then
        log_warning "检测到现有CCPM安装"
        
        # 尝试检测版本
        if [ -f ".claude/VERSION" ]; then
            local current_version
            current_version=$(cat .claude/VERSION 2>/dev/null || echo "unknown")
            echo "当前版本: $current_version"
        fi
        
        echo ""
        echo "检测到现有CCPM项目，请选择："
        echo "  1) 备份并覆盖安装 (推荐)"
        echo "  2) 取消安装"
        echo ""
        
        while true; do
            read -p "请选择 [1-2]: " choice
            case $choice in
                1)
                    log_info "选择：备份并覆盖安装"
                    return 0
                    ;;
                2)
                    log_info "安装已取消"
                    exit 0
                    ;;
                *)
                    log_error "无效选择，请输入1或2"
                    ;;
            esac
        done
    fi
    
    return 0
}

detect_conflicts() {
    log_step "检查文件冲突..."
    
    # 检查关键文件冲突
    local conflict_files=("README.md" "LICENSE" ".gitignore")
    local conflicts_found=false
    
    for file in "${conflict_files[@]}"; do
        if [ -f "$file" ]; then
            if [ "$conflicts_found" = false ]; then
                log_warning "发现文件冲突："
                conflicts_found=true
            fi
            echo "  - $file"
        fi
    done
    
    if [ "$conflicts_found" = true ]; then
        echo ""
        echo "这些文件将被覆盖，是否继续？"
        while true; do
            read -p "继续安装？ [y/N]: " confirm
            case $confirm in
                [Yy]*)
                    log_info "确认继续安装"
                    return 0
                    ;;
                [Nn]*|"")
                    log_info "安装已取消"
                    exit 0
                    ;;
                *)
                    log_error "请输入 y 或 n"
                    ;;
            esac
        done
    fi
    
    return 0
}

# ============================================================================
# 安装核心函数
# ============================================================================

download_project() {
    log_step "下载CCPM Enhanced项目..."
    
    # 克隆项目
    if git clone "$REPO_URL" "$INSTALL_DIR" >/dev/null 2>&1; then
        log_info "项目下载完成"
        return 0
    else
        log_error "项目下载失败"
        echo "请检查网络连接或仓库地址"
        return 1
    fi
}

cleanup_git_files() {
    log_step "清理Git文件..."
    
    # 删除Git相关文件
    rm -rf .git 2>/dev/null || true
    rm -f .gitignore 2>/dev/null || true
    
    # 删除安装器目录（避免递归）
    rm -rf install 2>/dev/null || true
    
    log_info "Git文件清理完成"
}

cleanup_docs() {
    log_step "清理文档文件..."
    
    # 删除文档文件（用户只需要.claude文件夹）
    rm -f README.md 2>/dev/null || true
    rm -f README_CN.md 2>/dev/null || true
    rm -f AGENTS.md 2>/dev/null || true
    rm -f AGENTS-CN.md 2>/dev/null || true
    rm -f COMMANDS.md 2>/dev/null || true
    rm -f COMMANDS-CN.md 2>/dev/null || true
    rm -f DEVELOPMENT_LOG.md 2>/dev/null || true
    rm -f LICENSE 2>/dev/null || true
    rm -f screenshot.webp 2>/dev/null || true
    rm -f 使用建议.md 2>/dev/null || true
    
    log_info "文档文件清理完成 - 用户只获得.claude工作目录"
}

create_version_file() {
    log_step "创建版本信息..."
    
    # 创建版本文件
    mkdir -p .claude
    echo "$SCRIPT_VERSION" > .claude/VERSION
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > .claude/INSTALL_DATE
    
    log_info "版本信息已创建"
}

# ============================================================================
# 安装验证函数
# ============================================================================

verify_installation() {
    log_step "验证安装..."
    
    # 检查关键文件
    local essential_files=(
        ".claude/scripts/pm/status.sh"
        ".claude/scripts/pm/epic-status.sh"
        ".claude/scripts/pm/standup.sh"
        ".claude/commands/pm"
    )
    
    local missing_files=()
    for file in "${essential_files[@]}"; do
        if [ ! -e "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        log_error "安装不完整，缺少文件："
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi
    
    # 检查脚本权限
    chmod +x .claude/scripts/pm/*.sh 2>/dev/null || true
    
    log_info "安装验证通过"
    return 0
}

show_success_message() {
    echo ""
    log_success "CCPM Enhanced 安装成功！"
    echo ""
    echo "🚀 快速开始："
    echo "  查看项目状态:    ./.claude/scripts/pm/status.sh"
    echo "  生成日报:       ./.claude/scripts/pm/standup.sh"
    echo "  查看Epic状态:   ./.claude/scripts/pm/epic-status.sh <epic-name>"
    echo ""
    echo "📚 更多信息："
    echo "  文档目录:       ./.claude/commands/"
    echo "  示例项目:       ./examples/"
    echo ""
    echo "🎯 版本: $SCRIPT_VERSION"
    echo "📅 安装时间: $(date)"
    
    if [ -n "$BACKUP_DIR" ]; then
        echo ""
        echo "💾 原文件已备份至: $BACKUP_DIR"
        echo "   (如需要可手动删除)"
    fi
}

# ============================================================================
# 主程序
# ============================================================================

main() {
    echo "🎯 CCPM Enhanced 智能安装器 v$SCRIPT_VERSION"
    echo "=================================================="
    echo ""
    
    # 环境检测
    check_git || exit 1
    check_network || exit 1
    check_permissions || exit 1
    check_disk_space
    
    echo ""
    
    # 安装状态检测
    detect_existing_installation
    detect_conflicts
    
    echo ""
    
    # 创建备份
    if create_backup; then
        log_info "已创建安全备份"
    fi
    
    echo ""
    
    # 执行安装
    download_project || exit 1
    cleanup_git_files
    cleanup_docs
    create_version_file
    
    echo ""
    
    # 验证安装
    if verify_installation; then
        show_success_message
        
        # 清理备份（安装成功）
        if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
            echo ""
            read -p "安装成功！是否删除备份文件？ [y/N]: " cleanup_backup
            case $cleanup_backup in
                [Yy]*)
                    rm -rf "$BACKUP_DIR"
                    log_info "备份文件已清理"
                    ;;
                *)
                    log_info "备份文件保留: $BACKUP_DIR"
                    ;;
            esac
        fi
        
        # 取消错误处理（安装成功）
        trap - EXIT
        exit 0
    else
        log_error "安装验证失败"
        exit 1
    fi
}

# 执行主程序
main "$@"