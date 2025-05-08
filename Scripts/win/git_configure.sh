#!/bin/bash

set -e

windows_terminal_home="D:\WindowsTerminal"
windows_terminal_version="1.20.11781.0"

git_home="D:\local\git"

# link
mklink_opt_windows="D:\opt"
mklink_opt_linux="$git_home\opt" # /opt

mklink_local_windows="D:\local"
mklink_local_linux="$git_home\usr\local" # /usr/local


# linux 目录链接, 用于在 bash 环境中模拟 lunux 目录结构
linux_symbolic() {
  echo -e "\033[32mconfigure linux symbolic link.\033[0m"

  # add mklink.bat
  cat > mklink.bat << EOF
@echo off
::echo param[0] = %0
::echo param[1] = %1
::echo param[2] = %2
mklink /J %1 %2
EOF

  if [[ ! -d "$mklink_opt_linux" ]]; then
    if [[ ! -d "$mklink_opt_windows" ]]; then
      mkdir -p "$mklink_opt_windows"
    fi
    ./mklink.bat "$mklink_opt_linux" "$mklink_opt_windows"
  fi

  if [[ ! -d "$mklink_local_linux" ]]; then
    if [[ ! -d "$mklink_local_windows" ]]; then
      mkdir -p "$mklink_local_windows"
    fi
    ./mklink.bat "$mklink_local_linux" "$mklink_local_windows"
  fi

  rm -rf mklink.bat
}


git_configure_vimrc() {
  # /etc/vimrc
  echo -e "\033[32mconfigure /etc/vimrc\033[0m"
  if ! grep -q $USERNAME "/etc/vimrc" ; then
    cat >> /etc/vimrc << EOF
" by $USERNAME
set noeb                     " 去除错误提示音
set number                   " 显示行号
set autoread                 " 自动加载文件改动
set expandtab                " 替换 Tab
set cursorline               " 突出显示当前行
set ignorecase               " 搜索忽略大小写
set noswapfile               " 禁用 swp 文件

set tabstop=2                " Tab键的宽度
set cmdheight=2              " 命令行高度

" set termguicolors            " 开启真彩色
" colorscheme habamax          " habamax pablo slate wildcharm
EOF
  fi
}


git_configure_inputrc() {
  # git-bash 删除键闪屏
  echo -e "\033[32mconfigure /etc/inputrc\033[0m"

  sed -i -s 's/set bell-style visible/set bell-style none/g' /etc/inputrc

  # 历史记录前缀搜索
  if ! grep -q $USERNAME "/etc/inputrc" ; then
    cat >> /etc/inputrc << EOF
# by $USERNAME
"\e[A": history-search-backward
"\e[B": history-search-forward
EOF
  fi
}


git_configure_profile() {
  # /etc/profile.d/aliases.sh
  # 移除 /etc/profile.d/aliases.sh 中 "alias ls='ls -F'" 部分，移除文件夹后面的 "/"
  echo -e "\033[32mconfigure /etc/profile.d/aliases.sh\033[0m"
  sed -i -s "s/^alias ls='ls -F /alias ls='ls /" /etc/profile.d/aliases.sh

  # /etc/profile.d/$USERPROFILE.sh
  echo -e "\033[32mconfigure /etc/profile.d/$USERNAME.sh\033[0m"
  if [[ ! -f "/etc/profile.d/$USERNAME.sh" ]]; then
    cat > /etc/profile.d/$USERNAME.sh << "EOF"
#!/usr/bin/env bash

# 将每个 session 的历史记录行追加到历史文件中
PROMPT_COMMAND='history -a'

# alias
alias l='ls -lhv'
alias la='ls -alhv'
alias open='start "" '

# git-for-windows
alias gitfetch='git fetch --all --prune'
alias gitreset='git reset --hard $(git branch --show-current)'

EOF
  fi

  # git-prompt.sh
  echo -e "\033[32mconfigure /etc/profile.d/git-prompt.sh\033[0m"
  curl -s -L https://raw.githubusercontent.com/charlesbases/applications/master/Git/git-prompt.sh --output /etc/profile.d/git-prompt.sh
}


git_configure_gitconfig() {
  # ~/.gitconfig (全局配置)
  echo -e "\033[32mconfigure gitconfig in $USERPROFILE\.gitconfig\033[0m"
  if [[ ! -f "$USERPROFILE\.gitconfig" ]]; then
    curl -s -L https://raw.githubusercontent.com/charlesbases/applications/master/Git/gitconfig --output "$USERPROFILE\.gitconfig"
  fi
}


git_configure() {
  git_configure_vimrc
  git_configure_inputrc
  git_configure_profile
  git_configure_gitconfig
}


install_windows_terminal() {
  if [[ -d "$windows_terminal_home" ]]; then return; fi

  echo && read -n 1 -p "Do you need to install Windows Terminal? (y/n)" install && echo
  if [[ ! "$install" =~ ^[yY]$ ]]; then exit; fi

  echo -e "\033[32mWindowsTerminal downloading...\033[0m"
  curl -s -L https://github.com/microsoft/terminal/releases/download/v${windows_terminal_version}/Microsoft.WindowsTerminal_${windows_terminal_version}_x64.zip --output windows_terminal_${windows_terminal_version}.zip

  echo -e "\033[32mWindowsTerminal installing...\033[0m"
  unzip -q windows_terminal_${windows_terminal_version}.zip -d windows_terminal
  cp -r "windows_terminal/terminal-$windows_terminal_version" "$windows_terminal_home"
  rm -rf windows_terminal*

  # settings.json
  echo -e "\033[32mWindowsTerminal configuring...\033[0m"
  local appdata="$USERPROFILE\AppData\Local\Microsoft\Windows Terminal"
  if [[ ! -d "$appdata" ]]; then
    mkdir -p "$appdata"
  fi
  curl -s -L https://raw.githubusercontent.com/charlesbases/applications/master/WindowsTerminal/settings.json --output "$appdata\settings.json"
  echo -e "\033[35mWindowsTerminal 1.20.11781.0 install complete.\033[0m"
}


# main
cd $git_home
read -n 1 -p "Please make sure the proxy is enabled. Continue? (y/n)" input && echo
if [[ ! "$input" =~ ^[yY]$ ]]; then exit; fi

linux_symbolic
git_configure

echo -e "\033[35mGit for Windows configure complete.\033[0m"


# install others
install_windows_terminal

echo && read -n 1 -p "Please enter any key to exit." input
