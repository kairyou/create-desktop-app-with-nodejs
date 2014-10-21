#!/bin/bash

# build node-webkit app
# start app: ./app.sh test-app -s
# build app: ./app.sh test-app -b

app_name=$1
action=$2
platform=$3

tmp=".tmp"
dist="dist"

osx_base="build/osx.zip"
win_base="build/win.zip"
linux_base="build/linux.tar.gz"

cmd="./build/node-webkit.app/Contents/MacOS/node-webkit"

help () {
    echo "$0 {app_name} {-b|-s}";exit
}

if [[ ! -d "$app_name" ]]; then
	help;
fi

# https://github.com/rogerwang/node-webkit#downloads
if [[ ! -f "$osx_base" ]]; then
	wget -O $osx_base -c http://dl.node-webkit.org/v0.10.5/node-webkit-v0.10.5-osx-x64.zip
fi
if [[ ! -f "$win_base" ]]; then
	wget -O $win_base -c http://dl.node-webkit.org/v0.10.5/node-webkit-v0.10.5-win-ia32.zip
fi
if [[ ! -f "$linux_base" ]]; then
	wget -O $linux_base -c http://dl.node-webkit.org/v0.10.5/node-webkit-v0.10.5-linux-x64.tar.gz
fi

build_mac () {
	contents="$tmp/osx/${app_name}.app/Contents"
	unzip $osx_base -d $tmp/ > /dev/null
	mv $tmp/node-webkit-*osx* $tmp/osx/
	mv $tmp/osx/node-webkit.app $tmp/osx/${app_name}.app
	if [ -f ${app_name}/Info.plist ];then
	    cp ${app_name}/Info.plist ${contents}
	fi
	cp $tmp/app.nw ${contents}/Resources/
	if [ -f ${app_name}/app.icns ];then
	    cp ${app_name}/app.icns ${contents}/Resources/
	fi
	rm -rf $tmp/osx/nwsnapshot $tmp/osx/credits.html
	echo "create osx app success!"
}
build_win () {
	contents="$tmp/win"
	unzip $win_base -d $tmp > /dev/null
	mv $tmp/node-webkit-*win* ${contents}
	cat ${contents}/nw.exe $tmp/app.nw > ${contents}/${app_name}.exe
	rm -rf ${contents}/nw.exe ${contents}/nwsnapshot.exe ${contents}/credits.html ${contents}/locales
	echo "create windows app success!"
}
build_linux () {
	contents="$tmp/linux"
	tar zxf $linux_base -C $tmp/
	mv $tmp/node-webkit-*linux* ${contents}
	cat ${contents}/nw $tmp/app.nw > ${contents}/${app_name} && chmod +x ${contents}/${app_name}
	rm -rf ${contents}/nw ${contents}/nwsnapshot ${contents}/credits.html ${contents}/locales
	echo "create linux app success!"
}

if [[ $action = '-b' ]]; then #build .nw
	if [[ ! -d "$dist" ]]; then
		mkdir $dist
	fi

	# creat nw
	rm -rf $tmp && mkdir $tmp
	cp -r ${app_name}/* $tmp
	rm -rf $tmp/Info.plist $tmp/app.icns
	zip -r $tmp/app.nw $tmp/* > /dev/null;
	rm -rf `find $tmp/* | egrep -v '(app.nw|.nw)'`
	echo "create .nw file success!"
	# exit;

	# build app (-w:windows, -l:linux, -m:mac)
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
	# del app.nw
	rm -f $tmp/app.nw

	mv $tmp/* $dist/
elif [[ $action = '-s' ]]; then #start
	$cmd ./${app_name}
elif [[ $action = '-c' ]]; then #clear dist + tmp
	rm -rf $dist $tmp
else
	help;
fi
