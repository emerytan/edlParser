const {
    app,
    BrowserWindow,
    ipcMain
} = require('electron')
const spawn = require('child_process').spawn
const exec = require('child_process').exec
const dialog = require('electron').dialog

let mainWindow

app.on('ready', function () {
    mainWindow = new BrowserWindow({
        width: 1000,
        height: 600,
        'min-width': 800,
        'min-height': 600,
        'accept-first-mouse': true,
        'title-bar-style': 'hidden'
    });
    mainWindow.loadURL(`file://${__dirname}/index.html`);
    // mainWindow.webContents.openDevTools()
    mainWindow.on('closed', function () {
        mainWindow = null;
    });
});

app.on('window-all-closed', function () {
    if (process.platform != 'darwin') {
        app.quit();
    }
});


ipcMain.on('asynchronous-message', function (event, arg) {
    let bashOutput = arg
    bashOutput = bashOutput.replace("Script", "Output")
    let parentcontainer = bashOutput.replace('bashOutput', 'container')

    console.log(parentcontainer);

    const run = spawn(`${__dirname}/bin/${arg}.sh`)

    run.stdout.on('data', (data) => {
        event.sender.send('asynchronous-reply', {
            data,
            bashOutput
        })
    })

    run.stderr.on('data', (data) => {
        event.sender.send('asynchronous-reply', {
            data,
            bashOutput
        })
    })
    
    run.on('close', (code) => {
        if (code !== 0) {
            event.sender.send('asynchronous-reply', {
                data: code,
                bashOutput
            })
        } else {
            event.sender.send('asynchronous-reply', {
                data: code,
                bashOutput                
            })
        }
    })
})
