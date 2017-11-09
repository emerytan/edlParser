const ipc = require('electron').ipcRenderer
const { StringDecoder } = require('string_decoder')
const decoder = new StringDecoder('utf8')
const $ = jQuery = require('jquery')
var count = 0

document.getElementById('buttons').addEventListener('click', (element) => {
  let clickedButton = event.srcElement.id
  ipc.send('asynchronous-message', clickedButton)
})

$('#debugMessages').text('jquery works')

ipc.on('asynchronous-reply', function (event, arg) {  
  // let pinToBottom = document.getElementById(arg.bashOutput)
  // document.getElementById(arg.bashOutput).textContent += 

  if (arg.data == '\r') {
    count += 1;
    console.log(count);
  }

  $('#bashOutput2').append(decoder.write(arg.data))
  var c = $(arg.bashOutput).parent()

  // pinToBottom.scrollTop = pinToBottom.scrollHeight
})


