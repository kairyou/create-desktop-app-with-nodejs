'use strict';

var app = null
    , mainWindow = null
    , menus = {appMenu: [], contextMenu: []};

var appMenu = menus['appMenu'];
var contextMenu = menus['contextMenu'];

appMenu['darwin'] = [{
    label: 'Atom Shell',
    submenu: [{
        label: 'About Atom Shell',
        selector: 'orderFrontStandardAboutPanel:'
    }, {
        type: 'separator'
    }, {
        label: 'Services',
        submenu: []
    }, {
        type: 'separator'
    }, {
        label: 'Hide Atom Shell',
        accelerator: 'Command+H',
        selector: 'hide:'
    }, {
        label: 'Hide Others',
        accelerator: 'Command+Shift+H',
        selector: 'hideOtherApplications:'
    }, {
        label: 'Show All',
        selector: 'unhideAllApplications:'
    }, {
        type: 'separator'
    }, {
        label: 'Quit',
        accelerator: 'Command+Q',
        click: function() {
            app.quit();
        }
    }, ]
}, {
    label: 'Edit',
    submenu: [{
        label: 'Undo',
        accelerator: 'Command+Z',
        selector: 'undo:'
    }, {
        label: 'Redo',
        accelerator: 'Shift+Command+Z',
        selector: 'redo:'
    }, {
        type: 'separator'
    }, {
        label: 'Cut',
        accelerator: 'Command+X',
        selector: 'cut:'
    }, {
        label: 'Copy',
        accelerator: 'Command+C',
        selector: 'copy:'
    }, {
        label: 'Paste',
        accelerator: 'Command+V',
        selector: 'paste:'
    }, {
        label: 'Select All',
        accelerator: 'Command+A',
        selector: 'selectAll:'
    }, ]
}, {
    label: 'View',
    submenu: [{
        label: 'Reload',
        accelerator: 'Command+R',
        click: function() {
            mainWindow.restart();
        }
    }, {
        label: 'Enter Fullscreen',
        click: function() {
            mainWindow.setFullScreen(true);
        }
    }, {
        label: 'Toggle DevTools',
        accelerator: 'Alt+Command+I',
        click: function() {
            mainWindow.toggleDevTools();
        }
    }, ]
}, {
    label: 'Window',
    submenu: [{
        label: 'Minimize',
        accelerator: 'Command+M',
        selector: 'performMiniaturize:'
    }, {
        label: 'Close',
        accelerator: 'Command+W',
        selector: 'performClose:'
    }, {
        type: 'separator'
    }, {
        label: 'Bring All to Front',
        selector: 'arrangeInFront:'
    }, ]
}];
// win, linux
appMenu['default'] = [{
    label: 'File',
    submenu: [{
        label: '&Open',
        accelerator: 'Ctrl+O',
    }, {
        label: '&Close',
        accelerator: 'Ctrl+W',
        click: function() {
            mainWindow.close();
        }
    }, ]
}, {
    label: 'View',
    submenu: [{
        label: '&Reload',
        accelerator: 'Ctrl+R',
        click: function() {
            mainWindow.restart();
        }
    }, {
        label: '&Enter Fullscreen',
        click: function() {
            mainWindow.setFullScreen(true);
        }
    }, {
        label: '&Toggle DevTools',
        accelerator: 'Alt+Ctrl+I',
        click: function() {
            mainWindow.toggleDevTools();
        }
    }, ]
}];

contextMenu['default'] = [
    { label: 'Item1', type: 'radio' },
    { label: 'Item2', type: 'radio' },
    { label: 'Item3', type: 'radio', clicked: true },
    { label: 'quit', type: 'radio', click: function() {
        app.quit();
    }}
];

module.exports = function(platform, mApp, mWin) {
    mainWindow = mWin;
    app = mApp;
    var ret = {
        appMenu: appMenu[platform] || appMenu['default']
        , contextMenu: contextMenu[platform] || contextMenu['default']
    }
    return ret;
}