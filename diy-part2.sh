#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 修改openwrt登陆地址
#sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

pushd package/lean/default-settings/files
# 版本号里显示一个自己的名字
sed -i "s/OpenWrt/WoodJ build $(TZ=UTC-8 date "+%y.%m.%d") @/g" zzz-default-settings
# 设置密码为空（安装固件时无需密码登陆，然后自己修改想要的密码）
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' zzz-default-settings
sed -i '/http/d' zzz-default-settings
export orig_version="$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')"
sed -i "s/${orig_version}/${orig_version} ($(date +"%Y-%m-%d"))/g" zzz-default-settings
popd

# Fix libssh
pushd feeds/packages/libs
rm -rf libssh
svn co https://github.com/openwrt/packages/trunk/libs/libssh
popd

# 总是拉取官方golang版本，避免xray&v2ray编译错误
pushd feeds/packages/lang
rm -fr golang && svn co https://github.com/openwrt/packages/trunk/lang/golang
popd

# 使用Lienol https-dns-proxy版本
pushd feeds/packages/net
rm -fr https-dns-proxy && svn co https://github.com/Lienol/openwrt-packages/trunk/net/https-dns-proxy
popd
pushd feeds/luci/applications
rm -fr luci-app-https-dns-proxy && svn co https://github.com/Lienol/openwrt-luci/branches/17.01/applications/luci-app-https-dns-proxy
popd

# let pdnsd filter aaaa
mv $GITHUB_WORKSPACE/pdnsd-patch/* $GITHUB_WORKSPACE/openwrt/package/lean/pdnsd-alt/patches
#======================================================================================
# 修改 argon 为默认主题,不再集成luci-theme-bootstrap主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
