#!/bin/bash

set -e

# 导出本地配置文件

dirname="."

application=""
setting_data="setting"
setting_file="setting.zip"

# 选择配置文件夹
COLUMNS=1
PS3="select: "
while true; do
  clear
  dirs=($(find $dirname -path "*/$setting_data" -prune -o -type d -depth 1 -print | sort | awk -v ORS=" " '{print $0}'))
  # 已经抵达最底层目录
  if [ -z "$dirs" ]; then
    # 判断 setting.zip 是否存在
    if [ ! -f "$dirname/$setting_file" ]; then
      echo -e "\033[31m$setting_file: no such file in $dirname\033[0m"
      exit
    fi

    # 解压目录已存在
    if [ -d "$dirname/$setting_data" ]; then
      read -rp "$setting_data already exists, do you want to delete it? (Y/N): " opt
      if [[ "$opt" == [Yy] ]]; then
        rm -rf "$dirname/$setting_data"
      fi
    fi

    break
  fi

  select dir in ${dirs[@]}; do
    if [ -z $dir ]; then
      exit
    fi

    dirname=$dir

    # application
    if [ -z "$application" ]; then
      case $dir in
        ./goland)
          application="GoLand"
        ;;
        *)
          echo -e "\033[31munsupported\033[0m"
          exit
        ;;
      esac
    fi

    # recursion
    break
  done
done

# 更改为相对路径
setting_data="$dirname/$setting_data"
setting_file="$dirname/$setting_file"

# 软件版本
application_version="$(basename $dirname)"

# 判断操作系统
case "$(uname -s)" in
  Linux*)
    linux
  ;;
  Darwin*)
    application_data="/Users/sun/Library/Application Support/JetBrains/$application$application_version"
  ;;
  MSYS*)
    application_data="$APPDATA\JetBrains\GoLand$application_version"
  ;;
  *)
    echo -e "\033[31munsupported system of $(uname -s)"
    exit
esac

# 解压配置文件, 获取文件列表
unzip -q -d "./$setting_data" "$setting_file"

# 从本地配置文件同步
find $setting_data -path "*/plugins" -prune -o -path "*/.DS_Store" -prune -o -path "*/__MACOSX" -prune -o -type f -print | sed "s@$setting_data/@@" | sort | while read file; do
  if [ -f "$application_data/$file" ]; then
    if [ -z $(diff "$application_data/$file" "$setting_data/$file" | head -n 1) ]; then
      echo "[S] $application_data/$file"
    else
      cp -f "$application_data/$file" "$setting_data/$file"
      echo -e "\033[32m[Y] $application_data/$file\033[0m"
    fi
  else
    echo -e "\033[31m[N] $application_data/$file\033[0m"
  fi
done

# 临时 session 切换目录并压缩文件
(cd $setting_data && zip -rq "$(basename $setting_data).zip" . && open .)
