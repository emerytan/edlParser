const {
  dialog
} = require('electron').remote
const {
  spawn,
  exec
} = require('child_process')
const ipc = require('electron').ipcRenderer
const path = require('path')
const fs = require('fs')
const {
  StringDecoder
} = require('string_decoder')
const decoder = new StringDecoder('utf8')
const $ = jQuery = require('jquery')

var userOptions = {

}

function parse(a, param) {
  const script = spawn('bash', [a, param])

  script.on('error', (error) => {
    console.log(error);
    $('#bashOutput1').append(decoder.write(error))
  })

  script.stdout.on('data', (data) => {
    let pin = document.getElementById('bashOutput1')
    pin.innerText += decoder.write(data)
    pin.scrollTop = pin.scrollHeight
  })

  script.stderr.on('data', (data) => {
    $('#bashOutput1').append(decoder.write(data))
  })

  script.on('exit', (code) => {
    $('#bashOutput1').append(decoder.write(code))
  })
}


document.getElementById('setBasePath').addEventListener('click', (element, event) => {
  dialog.showOpenDialog({
    properties: ['openDirectory']
  }, (selection) => {
    userOptions.basePath = selection[0]
    document.getElementById('basePath').innerText = selection


  })
}, false)

document.getElementById('getEDL').addEventListener('click', (element, event) => {
  dialog.showOpenDialog({
    properties: ['openFile']
  }, (selection) => {
    userOptions.EDL = path.basename(selection[0])
    document.getElementById('EDL').innerText = path.basename(selection[0])
  })
}, false)

document.getElementById('getSource').addEventListener('click', (element, event) => {
  dialog.showOpenDialog({
    properties: ['openDirectory']
  }, (selection) => {
    userOptions.srcPath = path.relative(userOptions.basePath, selection[0])
    document.getElementById('srcPath').innerText = userOptions.srcPath
  })
}, false)


document.getElementById('getDestination').addEventListener('click', (element, event) => {
  dialog.showOpenDialog({
    properties: ['openDirectory']
  }, (selection) => {
    userOptions.destPath = path.relative(userOptions.basePath, selection[0])
    document.getElementById('destPath').innerText = userOptions.destPath
  })
}, false)


document.getElementById('runScript').addEventListener('click', (element, event) => {
  $('#bashOutput1').text('cross your fingers....')
}, false)



// document.getElementById('buttons').addEventListener('click', (element, event) => {
//   let clickedButton = element.target.id
//   if (clickedButton === 'getEDL') {
//     let scriptPath = path.relative(process.cwd(), './scripts/gcEDLparser.sh')
//     let scriptArg = path.resolve(process.cwd(), './scripts/TTF_PIX LOCK_021518_V4_VFXPULLS.edl')
//     parse(scriptPath, scriptArg)
//   }
// }, false)