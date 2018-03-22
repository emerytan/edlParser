const ipc = require('electron').ipcRenderer
const {
  StringDecoder
} = require('string_decoder')
const decoder = new StringDecoder('utf8')
const $ = jQuery = require('jquery')
var count = 0

document.getElementById('buttons').addEventListener('click', (element, event) => {
  console.log(element.target.id);
  let clickedButton = element.target.id
  ipc.send('asynchronous-message', clickedButton)
})

$('#debugMessages').text('jquery works')

ipc.on('asynchronous-reply', function (event, arg) {
  let pinToBottom = document.getElementById(arg.bashOutput)
  document.getElementById(arg.bashOutput).textContent += decoder.write(arg.data)


  $('#bashOutput2').append(decoder.write(arg.data))
  var c = $(arg.bashOutput).parent()

  // pinToBottom.scrollTop = pinToBottom.scrollHeight
})