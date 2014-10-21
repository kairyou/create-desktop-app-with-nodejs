/* global require, __dirname, process */

// https://github.com/atom/atom-shell/blob/master/atom/browser/default_app/default_app.js

'use strict';

var app = require('app')
	, Menu = require('menu')
	// , MenuItem = require('menu-item')
	// , dialog = require('dialog')
	, BrowserWindow = require('browser-window'); // Module to create native browser window.
var fs = require('fs')
	, path = require('path');
var platform = process.platform;

// reports crashes to github
require('crash-reporter').start();

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the javascript object is GCed.
var mainWindow = null;

var resources_path = __dirname.indexOf('.asar') > 0 ? path.dirname(__dirname) : __dirname; // resources 目录

app.on('quit', function() {
	
});
// Quit when all windows are closed
app.on('window-all-closed', function() {
	// if (app.listeners('window-all-closed').length == 1)
	app.quit();
});


var Tray = require('tray');

// ready for creating browser windows
app.on('ready', function() {

    // Create the browser window.
    mainWindow = new BrowserWindow({
        width: 800, height: 600
        ,'use-content-size': true
        ,resizable: false
        // ,frame: false
    });

    // 在BrowserWindow()后调用dock.hide(), 防止打开App时, mainWindow突然隐藏(is bug?)
    app.dock.hide(); // hide osx dock icon(会隐藏ApplicationMenu; 可配合Tray的menu使用)

	// Emitted when the window is closed.
	mainWindow.on('closed', function() {
		// Dereference the window object, usually you would store windows
		// in an array if your app supports multi windows, this is the time
		// when you should delete the corresponding element.
		mainWindow = null;
	});

	// mainWindow.openDevTools();
	/*mainWindow.on('devtools-opened', function(e) {
		mainWindow.closeDevTools();
	});*/

    // 设置菜单 (禁用:dock.hide() 才可以看到)
    var menus = require('./libs/menu')(platform, app, mainWindow);
    var appMenu = Menu.buildFromTemplate(menus.appMenu);
    Menu.setApplicationMenu(appMenu);

    // 设置托盘
    // var appIcon = new Tray('asar:' + __dirname + '/assets/icon_menu.png'); // Tray还不支持asar路径(所以, 单独建立文件夹读取)
    var appIcon = new Tray(resources_path + '/public/icon_menu.png');
    var contextMenu = Menu.buildFromTemplate(menus.contextMenu);
    appIcon.setToolTip('This is my application.');
    appIcon.setContextMenu(contextMenu);

    mainWindow.loadUrl('asar://' + __dirname + '/index.html');
    mainWindow.focus();
});

