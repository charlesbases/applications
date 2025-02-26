#!/bin/bash


#
application_version="$(basename $PWD)"
application_data="$APPDATA\JetBrains\GoLand$application_version"

setting_dir="setting"
setting_file="setting.zip"


# 同步配置文件
unzip -q -d "./$setting_dir" "$setting_file"
unzip -l setting.zip | awk '!/plugins/ && NR>3 && NF>=4 && $NF !~ /\/$/ {print $NF}' | head -n -2 | while read file; do
  if [[ -f "$application_data/$file" ]]; then
    cp -f "$application_data/$file" "./$setting_dir/$file"
  fi
done


# 打包配置文件
# cd "./$setting_dir" && zip -r "../$setting_file" *
start "" "$setting_dir"
