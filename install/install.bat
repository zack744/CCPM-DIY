@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM CCPM Enhanced - Windows Installation Script
REM Windows智能安装脚本
REM 
REM 功能：在Windows环境下安全安装CCPM Enhanced
REM 作者：CCPM Enhanced Project
REM ============================================================================

set REPO_URL=https://github.com/zack744/CCPM-DIY.git
set SCRIPT_VERSION=1.0.0
set INSTALL_DIR=.
set BACKUP_DIR=
set ERROR_COUNT=0

echo 🎯 CCMP Enhanced Windows安装器 v%SCRIPT_VERSION%
echo ==================================================
echo.

REM ============================================================================
REM 环境检测
REM ============================================================================

:check_git
echo 🔍 检查Git环境...
where git >nul 2>&1
if errorlevel 1 (
    echo ❌ 未找到Git命令
    echo.
    echo 请先安装Git：
    echo   下载地址: https://git-scm.com/downloads
    echo   或使用包管理器: winget install Git.Git
    echo.
    pause
    exit /b 1
)
echo ✅ Git环境正常

REM 获取Git版本
for /f "tokens=3" %%i in ('git --version') do set GIT_VERSION=%%i
echo    版本: %GIT_VERSION%
echo.

:check_network
echo 🔍 检查网络连接...
git ls-remote --exit-code %REPO_URL% >nul 2>&1
if errorlevel 1 (
    echo ❌ 无法连接到仓库: %REPO_URL%
    echo.
    echo 可能的解决方案：
    echo   1. 检查网络连接
    echo   2. 使用VPN或代理
    echo   3. 检查防火墙设置
    echo.
    pause
    exit /b 1
)
echo ✅ 网络连接正常
echo.

:check_permissions
echo 🔍 检查目录权限...
echo test > .write_test 2>nul
if errorlevel 1 (
    echo ❌ 当前目录没有写权限
    echo 请以管理员身份运行或切换到其他目录
    pause
    exit /b 1
)
del .write_test >nul 2>&1
echo ✅ 目录权限正常
echo.

REM ============================================================================
REM 检测现有安装
REM ============================================================================

:detect_existing
echo 🔍 检测现有安装...
if exist ".claude" (
    echo ⚠️  检测到现有CCPM安装
    
    if exist ".claude\VERSION" (
        set /p CURRENT_VERSION=<.claude\VERSION
        echo    当前版本: !CURRENT_VERSION!
    )
    
    echo.
    echo 检测到现有CCPM项目，请选择：
    echo   1^) 备份并覆盖安装 ^(推荐^)
    echo   2^) 取消安装
    echo.
    
    :choice_loop
    set /p choice="请选择 [1-2]: "
    if "!choice!"=="1" (
        echo ✅ 选择：备份并覆盖安装
        goto detect_conflicts
    ) else if "!choice!"=="2" (
        echo ✅ 安装已取消
        pause
        exit /b 0
    ) else (
        echo ❌ 无效选择，请输入1或2
        goto choice_loop
    )
)
echo ✅ 未检测到现有安装
echo.

:detect_conflicts
echo 🔍 检查文件冲突...
set CONFLICTS_FOUND=0
set CONFLICT_FILES=README.md LICENSE .gitignore

for %%f in (%CONFLICT_FILES%) do (
    if exist "%%f" (
        if !CONFLICTS_FOUND!==0 (
            echo ⚠️  发现文件冲突：
            set CONFLICTS_FOUND=1
        )
        echo   - %%f
    )
)

if !CONFLICTS_FOUND!==1 (
    echo.
    echo 这些文件将被覆盖，是否继续？
    
    :confirm_loop
    set /p confirm="继续安装？ [y/N]: "
    if /i "!confirm!"=="y" (
        echo ✅ 确认继续安装
    ) else if /i "!confirm!"=="n" (
        echo ✅ 安装已取消
        pause
        exit /b 0
    ) else if "!confirm!"=="" (
        echo ✅ 安装已取消
        pause
        exit /b 0
    ) else (
        echo ❌ 请输入 y 或 n
        goto confirm_loop
    )
)
echo.

REM ============================================================================
REM 创建备份
REM ============================================================================

:create_backup
echo 🔍 检查是否需要备份...
dir /b >nul 2>&1
if not errorlevel 1 (
    for /f %%i in ('dir /b ^| find /c /v ""') do set FILE_COUNT=%%i
    if !FILE_COUNT! gtr 0 (
        for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set DATE_PART=%%c%%a%%b
        for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME_PART=%%a%%b
        set TIME_PART=!TIME_PART: =0!
        set BACKUP_DIR=.ccpm-backup-!DATE_PART!_!TIME_PART!
        
        echo 🔍 创建备份: !BACKUP_DIR!
        mkdir "!BACKUP_DIR!"
        
        for %%f in (*) do (
            if "%%f" neq "!BACKUP_DIR!" (
                xcopy "%%f" "!BACKUP_DIR!\" /E /I /H /Y >nul 2>&1
            )
        )
        echo ✅ 备份完成: !BACKUP_DIR!
    )
)
echo.

REM ============================================================================
REM 执行安装
REM ============================================================================

:download_project
echo 🔍 下载CCMP Enhanced项目...
git clone %REPO_URL% %INSTALL_DIR% >nul 2>&1
if errorlevel 1 (
    echo ❌ 项目下载失败
    echo 请检查网络连接或仓库地址
    goto restore_backup
)
echo ✅ 项目下载完成
echo.

:cleanup_git_files
echo 🔍 清理Git文件...
if exist ".git" rmdir /s /q .git >nul 2>&1
if exist ".gitignore" del /q .gitignore >nul 2>&1
if exist "install" rmdir /s /q install >nul 2>&1
echo ✅ Git文件清理完成
echo.

:cleanup_docs
echo 🔍 清理文档文件...
if exist "README.md" del /q "README.md" >nul 2>&1
if exist "README_CN.md" del /q "README_CN.md" >nul 2>&1
if exist "AGENTS.md" del /q "AGENTS.md" >nul 2>&1
if exist "AGENTS-CN.md" del /q "AGENTS-CN.md" >nul 2>&1
if exist "COMMANDS.md" del /q "COMMANDS.md" >nul 2>&1
if exist "COMMANDS-CN.md" del /q "COMMANDS-CN.md" >nul 2>&1
if exist "DEVELOPMENT_LOG.md" del /q "DEVELOPMENT_LOG.md" >nul 2>&1
if exist "LICENSE" del /q "LICENSE" >nul 2>&1
if exist "screenshot.webp" del /q "screenshot.webp" >nul 2>&1
if exist "使用建议.md" del /q "使用建议.md" >nul 2>&1
echo ✅ 文档文件清理完成 - 用户只获得.claude工作目录
echo.

:create_version_file
echo 🔍 创建版本信息...
if not exist ".claude" mkdir .claude
echo %SCRIPT_VERSION% > .claude\VERSION
for /f "tokens=*" %%i in ('powershell -command "Get-Date -format 'yyyy-MM-ddTHH:mm:ssZ'"') do echo %%i > .claude\INSTALL_DATE
echo ✅ 版本信息已创建
echo.

REM ============================================================================
REM 验证安装
REM ============================================================================

:verify_installation
echo 🔍 验证安装...
set MISSING_FILES=
set ESSENTIAL_FILES=.claude\scripts\pm\status.sh .claude\scripts\pm\epic-status.sh .claude\scripts\pm\standup.sh .claude\commands\pm

for %%f in (%ESSENTIAL_FILES%) do (
    if not exist "%%f" (
        set MISSING_FILES=!MISSING_FILES! %%f
    )
)

if not "!MISSING_FILES!"=="" (
    echo ❌ 安装不完整，缺少文件：
    for %%f in (!MISSING_FILES!) do echo   - %%f
    goto restore_backup
)

echo ✅ 安装验证通过
echo.

REM ============================================================================
REM 显示成功信息
REM ============================================================================

:show_success
echo.
echo 🎉 CCPM Enhanced 安装成功！
echo.
echo 🚀 快速开始：
echo   查看项目状态:    bash .claude/scripts/pm/status.sh
echo   生成日报:       bash .claude/scripts/pm/standup.sh
echo   查看Epic状态:   bash .claude/scripts/pm/epic-status.sh ^<epic-name^>
echo.
echo 📚 更多信息：
echo   文档目录:       .claude\commands\
echo   示例项目:       examples\
echo.
echo 🎯 版本: %SCRIPT_VERSION%
echo 📅 安装时间: %date% %time%

if not "!BACKUP_DIR!"=="" (
    echo.
    echo 💾 原文件已备份至: !BACKUP_DIR!
    echo    ^(如需要可手动删除^)
    echo.
    set /p cleanup_backup="安装成功！是否删除备份文件？ [y/N]: "
    if /i "!cleanup_backup!"=="y" (
        rmdir /s /q "!BACKUP_DIR!"
        echo ✅ 备份文件已清理
    ) else (
        echo ✅ 备份文件保留: !BACKUP_DIR!
    )
)

echo.
echo 安装完成！按任意键退出...
pause >nul
exit /b 0

REM ============================================================================
REM 错误处理
REM ============================================================================

:restore_backup
if not "!BACKUP_DIR!"=="" if exist "!BACKUP_DIR!" (
    echo 🔍 安装失败，恢复备份文件...
    
    REM 清理失败的安装
    for %%f in (*) do (
        if "%%f" neq "!BACKUP_DIR!" (
            if exist "%%f\" (
                rmdir /s /q "%%f" >nul 2>&1
            ) else (
                del /q "%%f" >nul 2>&1
            )
        )
    )
    
    REM 恢复备份
    xcopy "!BACKUP_DIR!\*" . /E /I /H /Y >nul 2>&1
    rmdir /s /q "!BACKUP_DIR!"
    echo ✅ 备份已恢复
)

echo.
echo ❌ 安装失败！
pause
exit /b 1