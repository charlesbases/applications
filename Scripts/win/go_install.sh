#!/bin/bash

GO_VERSION="1.23.12"

GOHOME="D:\local\go"
GOHOME_LINUX="/usr/local/go" # to linux  `mklink /J D:\local\git\bin\..\opt `

GOPATH="D:\opt\go"
GOPATH_LINUX="/opt/go" # to linux

GOSUMDB="off"
GOPROXY="https://goproxy.io,direct"
GO111MODULE="on"

# goland
IDE_HOME="D:\JetBrains\goland"
IDE_VERSION="2024.3.6"
IDE_VERSION_SHORT="2024.3"

#
environment_user="HKCU:\Environment"
environment_system="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"


windows_alias_install() {
  # start
  cat > start.bat << EOF
@echo off
::echo param[0] = %0
::echo param[1] = %1
start /wait "" %1
EOF
}


windows_alias_uninstall() {
  rm -rf "start.bat"
}


# 添加 windows 系统变量
# $1: key
# $2: value
configure_windows_environment() {
  # 判断系统变量是否非空
  if [[ "$(powershell -Command "Get-ItemProperty '$environment_system'" | awk -F' ' 'NF>0 {print $1}' | grep -w $1)" ]]; then
    return
  fi

  echo -e "\033[32m  add windows environment $1=$2\033[0m"
  powershell -Command "Set-ItemProperty -Path '$environment_system' -Name '$1' -Value '$2'"
}


configure_windows() {
  # 删除用户变量
  powershell -Command "Remove-ItemProperty -Path '$environment_user' -Name 'PATH'" &>/dev/null
  powershell -Command "Remove-ItemProperty -Path '$environment_user' -Name 'GOPATH'" &>/dev/null

  configure_windows_environment "GOPATH" "$GOPATH"
  configure_windows_environment "GOSUMDB" "$GOSUMDB"
  configure_windows_environment "GOPROXY" "$GOPROXY"
  configure_windows_environment "GO111MODULE" "$GO111MODULE"

  # add to PATH
  if [[ -z "$(echo $PATH | awk -v RS=: 'NF>0 {print}' | grep -w "$GOPATH_LINUX/bin")" ]]; then
    local current_path="$(powershell -Command "(Get-ItemProperty '$environment_system' -Name 'PATH').PATH")"
    powershell -Command "Set-ItemProperty -Path '$environment_system' -Name 'PATH' -Value '$current_path;$GOPATH\bin'"
  fi
}


configure_gitforwindows() {
  if [[ -z "$(grep -w "^# golang" /etc/profile.d/$USERNAME.sh)" ]]; then
    echo -e "\033[32m  add git environment GOHOME=$GOHOME_LINUX\033[0m"
    echo -e "\033[32m  add git environment GOPATH=$GOPATH_LINUX\033[0m"
    echo -e "\033[32m  add git environment GOSUMDB=off\033[0m"
    echo -e "\033[32m  add git environment GOPROXY=https://goproxy.io,direct\033[0m"
    echo -e "\033[32m  add git environment GO111MODULE=on\033[0m"

    cat >> /etc/profile.d/$USERNAME.sh << "EOF"

# environments
export PATH="$PATH:/opt/go/bin"

EOF

    cat >> /etc/profile.d/$USERNAME.sh << EOF
# golang
export GOHOME="$GOHOME_LINUX"
export GOPATH="$GOPATH_LINUX"
export GOSUMDB="off"
export GOPROXY="https://goproxy.io,direct"
export GO111MODULE="on"

alias cs="cd $GOPATH_LINUX/src"

EOF

    source /etc/profile.d/$USERNAME.sh
    mkdir -p $GOPATH/{bin,pkg,src}
  fi
}


install_go() {
  if [[ -d "$GOHOME" ]]; then return; fi

  echo -e "\033[32mgo installing...\033[0m"

  # install
  curl -s -L "https://dl.google.com/go/go${GO_VERSION}.windows-amd64.msi" --output "go${GO_VERSION}.msi"
  ./start.bat "go${GO_VERSION}.msi"
  rm -rf "go${GO_VERSION}.msi"

  # install failed
  if [[ ! -d "$GOHOME" ]]; then
    echo -e "\033[31mgo$GO_VERSION install failed.\033[0m"
    return
  fi

  # configure goland
  echo -e "\033[32mgo configuring...\033[0m"

  configure_windows
  configure_gitforwindows

  # complete
  echo -e "\033[35mgo$GO_VERSION install complete.\033[0m"
}


install_ide() {
  if [[ -d "$IDE_HOME" ]]; then return; fi

  echo && read -n 1 -p "Do you need to install goland-$IDE_VERSION? (y/n)" install && echo
  if [[ ! "$install" =~ ^[yY]$ ]]; then exit; fi

  echo -e "\033[32mgoland downloading...\033[0m"
  curl -s -L "https://download.jetbrains.com/go/goland-$IDE_VERSION.exe" --output goland-$IDE_VERSION.exe

  echo -e "\033[32mgoland installing...\033[0m"
  ./start.bat "goland-$IDE_VERSION.exe"
  rm -r "goland-$IDE_VERSION.exe"

  # install failed
  if [[ ! -d "$IDE_HOME" ]]; then
    echo -e "\033[31mgoland install failed.\033[0m"
    return
  fi

  # configure goland
  echo -e "\033[32mgoland configuring...\033[0m"
  local appdata="$USERPROFILE\AppData\Roaming\JetBrains\GoLand$IDE_VERSION_SHORT"
  if [ -d "$appdata" ]; then rm -rf $appdata; fi
  mkdir -p $appdata &>/dev/null

  curl -s -L https://raw.githubusercontent.com/charlesbases/applications/master/JetBrains/goland/win/$IDE_VERSION_SHORT/roaming.zip --output roaming.zip
  unzip -o -q roaming.zip -d $appdata

  curl -s -L https://raw.githubusercontent.com/charlesbases/applications/master/JetBrains/goland/win/$IDE_VERSION_SHORT/setting.zip --output setting.zip
  unzip -o -q setting.zip -d $appdata

  rm -rf goland-$IDE_VERSION.exe roaming.zip setting.zip

  # 删除安装目录下 llmInstaller
  rm -rf "$IDE_HOME\plugins\llmInstaller"
}


# main
read -n 1 -p "Please make sure the proxy is enabled. Continue? (y/n)" input && echo
if [[ ! "$input" =~ ^[yY]$ ]]; then exit; fi

windows_alias_install

install_go
install_ide

windows_alias_uninstall

echo && read -n 1 -p "Please enter any key to exit." input
