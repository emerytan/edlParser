const { spawn, exec } = require('child_process')
const ipc = require('electron').ipcRenderer
const { StringDecoder } = require('string_decoder')
const decoder = new StringDecoder('utf8')
const $ = jQuery = require('jquery')


document.getElementById('buttons').addEventListener('click', (element, event) => {
  console.log(element.target.id);
  let clickedButton = element.target.id
  ipc.send('asynchronous-message', clickedButton)
})

$('#debugMessages').text('jquery works')

ipc.on('asynchronous-reply', function (event, arg) {
  let pinToBottom = document.getElementById(arg.bashOutput)
  document.getElementById(arg.bashOutput).textContent += decoder.write(arg.data)

})


const script = spawn('./bin/clients/1619/2017/ltocontrol/bashScripts/statTape1.sh')

script.stderr.on('data', (data) => {
  document.getElementById('debugMessages').innerText += decoder.write(data)
})

script.stdout.on('data', (data) => {
  document.getElementById('bashOutput1').textContent += decoder.write(data)
})

script.on('error', (error) => {
  console.log(error);
})
