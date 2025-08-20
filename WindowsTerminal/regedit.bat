@echo off

:: 检查是否以管理员身份运行
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 请以管理员身份运行此脚本！
    pause
    exit /b
)

:: 定义 Windows Terminal 路径
set "wtPath=D:\WindowsTerminal\WindowsTerminal.exe"

:: 1. 添加文件夹右键菜单（在当前窗口打开新标签页）
reg add "HKEY_CLASSES_ROOT\Directory\shell\WindowsTerminal" /ve /d "Windows Terminal" /f
reg add "HKEY_CLASSES_ROOT\Directory\shell\WindowsTerminal" /v "Icon" /d "%wtPath%" /f
reg add "HKEY_CLASSES_ROOT\Directory\shell\WindowsTerminal\command" /ve /d "\"%wtPath%\" -w 0 -d \"%%V\"" /f

:: 2. 添加文件夹内空白处右键菜单（在当前窗口打开新标签页）
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal" /ve /d "Windows Terminal" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal" /v "Icon" /d "%wtPath%" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal\command" /ve /d "\"%wtPath%\" -w 0 -d \"%%V\"" /f

:: 3. 刷新资源管理器
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

pause