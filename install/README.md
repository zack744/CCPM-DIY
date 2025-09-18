# 🚀 CCPM Enhanced - 零基础安装指南

[![Enhanced Version](https://img.shields.io/badge/Version-Enhanced-brightgreen)](https://github.com/zack744/CCPM-DIY)
[![Cross Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue)]()
[![Beginner Friendly](https://img.shields.io/badge/Beginner-Friendly-green)]()

> 🎯 **专为编程小白设计** - 即使你从未接触过编程，也能轻松安装使用的项目管理工具

## 📖 这是什么？

**CCPM Enhanced** 是一个超级强大的项目管理工具，可以帮你：
- 📊 **自动生成项目状态报告** - 不用手写汇报
- 📝 **生成日报周报** - 一键搞定工作总结  
- 🎯 **追踪项目进度** - 清楚知道还有什么没做完
- 🤖 **配合AI助手** - 让Claude等AI更好地帮助你

## 🆚 为什么选择Enhanced版本？

| 功能 | 普通版本 | Enhanced版本 |
|------|----------|-------------|
| **安装难度** | ❌ 需要技术背景 | ✅ **零基础可用** |
| **安装成功率** | ❌ 经常失败 | ✅ **智能容错** |
| **功能完整度** | ❌ 基础功能 | ✅ **专业级功能** |
| **跨平台支持** | ❌ 仅支持Mac/Linux | ✅ **全平台支持** |
| **出错恢复** | ❌ 出错就完蛋 | ✅ **自动备份恢复** |

---

## 🎯 极简安装 - 3分钟搞定

### 第一步：准备工作 🛠️

#### Windows用户 🪟
1. **安装Git** (必需)
   - 访问：https://git-scm.com/downloads
   - 下载"Windows"版本
   - 一路点"下一步"安装即可
   - 安装完成后重启电脑

2. **打开命令行工具**
   - 按 `Win + R` 键
   - 输入 `cmd` 然后按回车
   - 或者搜索"命令提示符"

#### Mac用户 🍎
1. **Git通常已预装**，如果没有：
   - 打开"终端"应用
   - 输入：`git --version`
   - 如果提示安装，点击"安装"

2. **打开终端**
   - 按 `Cmd + 空格`
   - 搜索"终端"并打开

#### Linux用户 🐧
1. **安装Git**：
   ```bash
   # Ubuntu/Debian
   sudo apt install git
   
   # CentOS/RHEL
   sudo yum install git
   ```

### 第二步：选择你的安装方式 🎯

我们提供了3种方式，**推荐方式1**（最简单）：

---

## 📦 方式1：一键智能安装（推荐）

### Windows用户 - 使用PowerShell
1. **右键开始菜单** → 选择"Windows PowerShell（管理员）"
2. **复制粘贴下面的命令**（一行搞定）：
```powershell
iwr -useb https://raw.githubusercontent.com/zack744/CCPM-DIY/main/install/install.bat -o install.bat; .\install.bat
```

### Windows用户 - 使用Git Bash（推荐）
1. **右键桌面** → 选择"Git Bash Here"
2. **复制粘贴下面的命令**：
```bash
curl -sSL https://raw.githubusercontent.com/zack744/CCPM-DIY/main/install/install.sh | bash
```

### Mac/Linux用户
1. **打开终端**
2. **复制粘贴下面的命令**：
```bash
curl -sSL https://raw.githubusercontent.com/zack744/CCPM-DIY/main/install/install.sh | bash
```

### 🎉 就是这么简单！
- 🔍 安装器会自动检测你的系统环境
- 🛡️ 自动备份现有文件（如果有的话）
- ✅ 自动验证安装是否成功
- 📝 显示下一步操作指南

---

## 📦 方式2：手动下载安装

如果上面的一键安装不行，试试这个：

### 步骤1：创建项目文件夹
```bash
# 创建一个新文件夹
mkdir my-project
cd my-project
```

### 步骤2：下载安装器
```bash
# 下载Windows版安装器
curl -O https://raw.githubusercontent.com/zack744/CCPM-DIY/main/install/install.bat

# 或下载Unix版安装器  
curl -O https://raw.githubusercontent.com/zack744/CCPM-DIY/main/install/install.sh
```

### 步骤3：运行安装器
```bash
# Windows
install.bat

# Mac/Linux
chmod +x install.sh
./install.sh
```

---

## 📦 方式3：Git克隆（给有经验的用户）

```bash
# 克隆项目
git clone https://github.com/zack744/CCPM-DIY.git my-project
cd my-project

# 清理Git文件
rm -rf .git install
```

---

## 🚀 安装完成后怎么使用？

安装成功后，你会看到类似这样的提示：

```
🎉 CCPM Enhanced 安装成功！

🚀 快速开始：
  查看项目状态:    ./.claude/scripts/pm/status.sh
  生成日报:       ./.claude/scripts/pm/standup.sh
  查看Epic状态:   ./.claude/scripts/pm/epic-status.sh <epic-name>
```

### 试试这些命令：

```bash
# 查看项目整体状态（最常用）
./.claude/scripts/pm/status.sh

# 生成今天的工作日报
./.claude/scripts/pm/standup.sh

# 查看所有可用的命令
ls ./.claude/commands/pm/
```

---

## 🆘 遇到问题怎么办？

### ❌ 提示"Git命令未找到"
**解决方案**：
1. 重新安装Git：https://git-scm.com/downloads
2. 安装完成后**重启电脑**
3. 重新打开命令行窗口

### ❌ 提示"网络连接失败"
**解决方案**：
1. 检查网络连接
2. 如果在公司网络，可能需要使用VPN
3. 尝试手机热点

### ❌ 提示"权限不足"
**解决方案**：
```bash
# Windows: 以管理员身份运行PowerShell
# Mac/Linux: 给脚本执行权限
chmod +x install.sh
```

### ❌ 安装过程中断或失败
**不用担心**！我们的安装器很智能：
- ✅ 会自动备份你的原始文件
- ✅ 如果安装失败，会自动恢复备份
- ✅ 你可以安全地重新尝试安装

---

