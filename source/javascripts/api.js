window.Electron = require('electron');

const UUID = require('uuid');

const requestEventHandlers = {};

window.Mkdirp = (path, cb) => {
  const id = UUID.v4();

  requestEventHandlers[id] = {
    callback: (error) => {
      requestEventHandlers[id] = null;
      cb(error);
    }
  }

  Electron.ipcRenderer.send('api', {
    id,
    apiName: 'mkdirp',
    apiOptions: {
      path
    }
  });
};

window.CallRequest = ({
  options,
  onData,
  onRequestData,
  onFinish,
  pipeRequest,
  pipeResponse
}) => {
  const id = UUID.v4();

  requestEventHandlers[id] = {
    onData,
    onRequestData,
    onFinish: (...args) => {
      requestEventHandlers[id] = null;
      onFinish(...args);
    }
  };

  Electron.ipcRenderer.send('api', {
    id,
    apiName: 'request',
    apiOptions: {
      options,
      pipeRequest,
      pipeResponse
    }
  });

  return {
    abort: () => {
      Electron.ipcRenderer.send('api', {
        apiName: 'request-abort',
        id: id
      });
    }
  };
};

Electron.ipcRenderer.on('api-event', (evt, {
  id,
  eventName,
  args
}) => {
  if (!requestEventHandlers[id] || !requestEventHandlers[id][eventName]) return;
  requestEventHandlers[id][eventName](...args);
});

window.SelectFiles = (cb) => {
  Electron.remote.dialog.showOpenDialog(
    Electron.remote.getCurrentWindow(), {
      properties: ['multiSelections', 'openFile', 'treatPackageAsDirectory']
    },
    cb
  );
};

window.SelectFolder = (cb) => {
  Electron.remote.dialog.showOpenDialog(
    Electron.remote.getCurrentWindow(), {
      properties: ['openDirectory', 'treatPackageAsDirectory']
    },
    filePaths => {
      if (!filePaths || !filePaths[0]) return;
      cb(filePaths[0]);
    }
  );
};

window.SaveAsFile = (filename, cb) => {
  Electron.remote.dialog.showSaveDialog(
    Electron.remote.getCurrentWindow(), {
      defaultPath: filename
    },
    cb
  );
};

window.Open = (action, params) => {
  const curWindow = Electron.remote.getCurrentWindow();
  const newWindow = new Electron.remote.BrowserWindow({
    parent: curWindow,
    x: curWindow.getPosition()[0] + 50,
    y: curWindow.getPosition()[1] + 50,
  });
  newWindow.loadURL(location.href);

  newWindow.webContents.on('did-finish-load', () => {
    newWindow.webContents.send('init-params', {
      action,
      params
    });
  });
};

window.Prompt = (title, cb) => {
  const id = UUID.v4();

  requestEventHandlers[id] = {
    callback: (path) => {
      requestEventHandlers[id] = null;
      cb(path);
    }
  }

  Electron.ipcRenderer.send('api', {
    id,
    apiName: 'prompt',
    apiOptions: {
      title
    }
  });
};

window.Crypto = require('crypto');
window.Path = require('path');
window.Fs = require('fs');
window.Ace = require('exports-loader?ace!ace-builds/src-noconflict/ace.js');

Electron.ipcRenderer.on('init-params', (evt, {
  action,
  params
}) => {
  Init(action, params);
});
