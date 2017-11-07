const ipc = require('electron').ipcRenderer
const { StringDecoder } = require('string_decoder')
const $ = jQuery = require('jquery')

document.getElementById('buttons').addEventListener('click', (element) => {
  let clickedButton = event.srcElement.id
  ipc.send('asynchronous-message', clickedButton)
})

$('#debugMessages').text('jquery works')

ipc.on('asynchronous-reply', function (event, arg) {  
  // let pinToBottom = document.getElementById(arg.bashOutput)
  document.getElementById(arg.bashOutput).textContent += arg.data.toString()
  var c = $(arg.bashOutput).parent()
  console.log(c)
  // pinToBottom.scrollTop = pinToBottom.scrollHeight
})


