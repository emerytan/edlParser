const { dialog } = require('electron').remote
const { spawn, exec } = require('child_process')
const ipc = require('electron').ipcRenderer
const { StringDecoder } = require('string_decoder')
const decoder = new StringDecoder('utf8')
const $ = jQuery = require('jquery')


document.getElementById('buttons').addEventListener('click', (element, event) => {
  
  let clickedButton = element.target.id

})

$('#debugMessages').text('jquery works')
