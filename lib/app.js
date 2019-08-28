const Electron = require('electron');
const ElectronUpdater = require('electron-updater');
const ElectronPrompt = require('electron-prompt');
const Path = require('path');
const URL = require('url');
const Request = require('request');
const Mkdirp = require('mkdirp');
const Fs = require('fs');

class App {
  constructor() {

    this.window = new Electron.BrowserWindow({
      webPreferences: {
        nodeIntegration: true
      }
    });

    this.window.loadURL(URL.format({
      pathname: Path.join(__dirname, '..', 'source', 'index.html'),
      protocol: 'file:',
      slashes: true
    }));

    this.window.webContents.on('did-finish-load', () => {
      this.window.webContents.send('init-params', {
        action: 'login',
        params: {}
      });
    });
  }

  static HandleAPIs() {
    const requests = {};

    Electron.ipcMain.on('api', (evt, {
      id,
      apiName,
      apiOptions
    }) => {

      if (apiName == 'request') {
        const {
          options,
          pipeRequest,
          pipeResponse
        } = apiOptions;

        const request = requests[id] = Request(options, (error, res, data) => {
          evt.sender.send('api-event', {
            id,
            eventName: 'onFinish',
            args: [
              error && {
                message: error.message
              },
              res && {
                statusCode: res.statusCode
              },
              data
            ]
          })
        })

        if (pipeRequest) {
          const readStream = Fs.createReadStream(pipeRequest);
          readStream.pipe(request);
          readStream.on('data', data => {
            evt.sender.send('api-event', {
              id,
              eventName: 'onRequestData',
              args: [data]
            });
          });
        }

        if (pipeResponse) {
          const writeStream = Fs.createWriteStream(pipeResponse);
          request.pipe(writeStream);
          writeStream.on('error', error => {
            evt.sender.send('api-event', {
              id,
              eventName: 'onFinish',
              args: [error]
            });

            // TODO: make sure request aborts in case of error
          });
        }

        request.on('data', (data) => {
          evt.sender.send('api-event', {
            id,
            eventName: 'onData',
            args: [data]
          });
        });
      }

      if (apiName == 'request-abort') {
        if (!requests[id]) return;
        requests[id].abort();
      }

      if (apiName == 'mkdirp') {
        const {
          path
        } = apiOptions;
        Mkdirp(path, error => {
          evt.sender.send('api-event', {
            id,
            eventName: 'callback',
            args: [error && {
              message: error.message
            }]
          });
        });
      }

      if (apiName == 'prompt') {
        const {
          title,
        } = apiOptions;
        ElectronPrompt({
          title: title
        }).then(path => {
          if (!path) return;
          evt.sender.send('api-event', {
            id,
            eventName: 'callback',
            args: [path]
          });
        }).catch(error => {});
      }
    });
  }
}

ElectronUpdater.autoUpdater.on('update-downloaded', () => {
  ElectronUpdater.quitAndInstall();
});

Electron.app.on('ready', () => {
  App.HandleAPIs();
  ElectronUpdater.autoUpdater.checkForUpdates();
  new App();

  Electron.Menu.setApplicationMenu(Electron.Menu.buildFromTemplate([{
    label: "Application",
    submenu: [{
        label: "About Application",
        selector: "orderFrontStandardAboutPanel:"
      },
      {
        type: "separator"
      },
      {
        label: "Quit",
        accelerator: "Command+Q",
        click: function() {
          Electron.app.quit();
        }
      }
    ]
  }, {
    label: "Edit",
    submenu: [{
        label: "Undo",
        accelerator: "CmdOrCtrl+Z",
        selector: "undo:"
      },
      {
        label: "Redo",
        accelerator: "Shift+CmdOrCtrl+Z",
        selector: "redo:"
      },
      {
        type: "separator"
      },
      {
        label: "Cut",
        accelerator: "CmdOrCtrl+X",
        selector: "cut:"
      },
      {
        label: "Copy",
        accelerator: "CmdOrCtrl+C",
        selector: "copy:"
      },
      {
        label: "Paste",
        accelerator: "CmdOrCtrl+V",
        selector: "paste:"
      },
      {
        label: "Select All",
        accelerator: "CmdOrCtrl+A",
        selector: "selectAll:"
      },
      {
        label: 'Developer Tools',
        accelerator: "CmdOrCtrl+Alt+I",
        click: (item, focusedWindow) => {
          if (focusedWindow) {
            const webContents = focusedWindow.webContents;
            if (webContents.isDevToolsOpened()) {
              webContents.closeDevTools();
            } else {
              webContents.openDevTools({
                mode: 'detach'
              });
            }
          }
        }
      }
    ]
  }]));
});

Electron.app.on('window-all-closed', () => {
  process.exit();
});
