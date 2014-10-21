#!/bin/bash

# build atom-shell app
# start app: ./app.sh test-app -s
# build app: ./app.sh test-app -b

app_name=$1
action=$2
platform=$3

tmp=".tmp"
dist="dist"

osx_base="osx.zip"
win_base="win.zip"
linux_base="linux.tar.gz"

cmd="./build/atom-shell/Atom.app/Contents/MacOS/Atom"

help () {
    echo "$0 {app_name} {-b|-s}";exit
}

if [[ ! -d "$app_name" ]]; then
	help;
fi

osx_base="build/osx.zip"
win_base="build/win.zip"
linux_base="build/linux.zip"

# https://github.com/atom/atom-shell/releases
if [[ ! -f "$osx_base" ]]; then
	wget -O $osx_base -c https://github.com/atom/atom-shell/releases/download/v0.18.0/atom-shell-v0.18.0-darwin-x64.zip
fi
if [[ ! -f "$win_base" ]]; then
	wget -O $win_base -c https://github.com/atom/atom-shell/releases/download/v0.18.0/atom-shell-v0.18.0-win32-ia32.zip
fi
if [[ ! -f "$linux_base" ]]; then
	wget -O $linux_base -c https://github.com/atom/atom-shell/releases/download/v0.18.0/atom-shell-v0.18.0-linux-x64.zip
fi


build_mac () {
	contents="$tmp/osx/${app_name}.app/Contents"
	unzip $osx_base -d $tmp/osx > /dev/null
	mv $tmp/osx/Atom.app $tmp/osx/${app_name}.app
	if [ -f ${app_name}/public/Info.plist ];then
	    cp ${app_name}/public/Info.plist ${contents}
	fi
	if [ -f ${app_name}/public/app.icns ];then
	    cp ${app_name}/public/app.icns ${contents}/Resources/
	fi
	rm -rf $tmp/osx/LICENSE $tmp/osx/version ${contents}/Resources/default_app ${contents}/Resources/*.lproj
	# ls ${contents}/Resources/
	cp $tmp/app.asar ${contents}/Resources/
	public="${contents}/Resources/public"
	cp -r ${app_name}/public ${public}
	rm -rf ${public}/Info.plist ${public}/app.icns
	echo "create osx app success!"
}
build_win () {
	contents="$tmp/win"
	unzip $win_base -d ${contents} > /dev/null
	mv ${contents}/Atom.exe ${contents}/${app_name}.exe
	rm -rf ${contents}/LICENSE ${contents}/version ${contents}/resources/default_app ${contents}/locales
	cp $tmp/app.asar ${contents}/resources
	public="${contents}/resources/public"
	cp -r ${app_name}/public ${public}
	rm -rf ${public}/Info.plist ${public}/app.icns
	echo "create windows app success!"
}
build_linux () {
	contents="$tmp/linux"
	unzip $linux_base -d ${contents} > /dev/null
	mv ${contents}/atom ${contents}/${app_name}
	rm -rf ${contents}/LICENSE ${contents}/version ${contents}/resources/default_app ${contents}/locales
	cp $tmp/app.asar ${contents}/resources
	public="${contents}/resources/public"
	cp -r ${app_name}/public ${public}
	rm -rf ${public}/Info.plist ${public}/app.icns
	echo "create linux app success!"
}

if [[ $action = '-b' ]]; then #build
	if [[ ! -d "$dist" ]]; then
		mkdir $dist
	fi

	# creat asar
	if ! `which asar > /dev/null 2>&1`; then # for pack
		npm install -g asar
	fi
	rm -rf $tmp && mkdir $tmp
	cp -r ${app_name}/* $tmp
	rm -rf $tmp/public # rm: Info.plist, app.icns, png..
	asar pack ${tmp} $tmp/app.asar
	# asar list $tmp/app.asar # list files
	rm -rf `find $tmp/* | egrep -v '(app.asar|.asar)'`
	echo "create .asar file success!"
	# exit;
	
	# build app (-w:windows, -l:linux, -m:mac), http://goo.gl/MNRTFk
	if [[ $platform = '-m' ]]; then # mac
		rm -rf $dist/osx
		build_mac;
	elif [[ $platform = '-w' ]]; then # windows
		rm -rf $dist/win
		build_win;
	elif [[ $platform = '-l' ]]; then # linux
		rm -rf $dist/linux
		build_linux;
	else # all
		rm -rf $dist/*
		build_mac;
		build_win;
		build_linux;
	fi
	# del app.asar
	rm -f $tmp/app.asar
	
	mv $tmp/* $dist/
elif [[ $action = '-s' ]]; then #start
	$cmd ./${app_name}
elif [[ $action = '-c' ]]; then #clear dist + tmp
	rm -rf $dist $tmp
else
	help;
fi
