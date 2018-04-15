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


window.onload = function () {
	ipc.send('init')
}


ipc.on('app path', (event, message) => {
	userOptions.thisPath = message.toString()
	document.getElementById('debugMessages').innerText = 'App initialized'
	document.getElementById('getEDL').disabled = true
	document.getElementById('getSource').disabled = true
	document.getElementById('getDestination').disabled = true
	document.getElementById('runScript').disabled = true
})

document.getElementById('setBasePath').addEventListener('click', (element, event) => {
	document.getElementById('bashOutput1').innerText = ''	
	dialog.showOpenDialog({
		buttonLabel: 'Set Base Path',
		properties: ['openDirectory']
	}, (selection) => {
		if (selection) {
			userOptions.basePath = selection[0]
			document.getElementById('basePath').innerText = selection
			document.getElementById('getEDL').disabled = false	
		} else {
			alert('You must select a base path to enable other functions')
		}
	})
}, false)


document.getElementById('getEDL').addEventListener('click', (element, event) => {
	dialog.showOpenDialog({
		buttonLabel: 'Get EDL',
		filters: [{
			name: 'EDLS',
			extensions: ['edl', 'EDL']
		}],
		properties: ['openFile']
	}, (selection) => {
		if (selection) {
			userOptions.EDL = selection[0]
			document.getElementById('EDL').innerText = path.basename(selection[0])
			document.getElementById('getSource').disabled = false
			document.getElementById('getDestination').disabled = false		
		} else {
			alert('you must select an EDL to enable other functions')
		}

	})
}, false)


document.getElementById('getSource').addEventListener('click', (element, event) => {
	dialog.showOpenDialog({
		defaultPath: userOptions.basePath,
		buttonLabel: 'Get Source Base',
		properties: ['openDirectory']
	}, (selection) => {
		userOptions.srcPath = path.relative(userOptions.basePath, selection[0])
		document.getElementById('srcPath').innerText = userOptions.srcPath
		if (userOptions.destPath) {
			document.getElementById('runScript').disabled = false
		}1
	})
}, false)


document.getElementById('getDestination').addEventListener('click', (element, event) => {
	dialog.showOpenDialog({
		defaultPath: userOptions.basePath,
		buttonLabel: 'Set Destination Path',
		properties: ['openDirectory']
	}, (selection) => {
		userOptions.destPath = path.relative(userOptions.basePath, selection[0])
		document.getElementById('destPath').innerText = userOptions.destPath
		if (userOptions.srcPath) {
			document.getElementById('runScript').disabled = false
		}
	})
}, false)


document.getElementById('runScript').addEventListener('click', (element, event) => {

	document.getElementById('bashOutput1').innerText = ''
	var myButtons = document.getElementsByTagName('button')
	
	for (let index = 0; index < myButtons.length; index++) {
		myButtons[index].disabled = true
	}

	let scriptPath = path.join(userOptions.thisPath, 'scripts/bin/gcEDLparser.sh')
	const runEDL = spawn(scriptPath, [
		userOptions.EDL,
		userOptions.basePath,
		userOptions.srcPath,
		userOptions. destPath
	])

	runEDL.on('error', (error) => {
		$('#bashOutput1').text(decoder.write(error))
	})

	runEDL.stdout.on('data', (data) => {
		let pin = document.getElementById('bashOutput1')
		pin.innerText += decoder.write(data)
		pin.scrollTop = pin.scrollHeight
	})

	runEDL.stderr.on('data', (data) => {
		let pin = document.getElementById('bashOutput1')
		pin.innerText += decoder.write(data)
		pin.scrollTop = pin.scrollHeight
	})

	runEDL.on('exit', (code) => {
		document.getElementById('setBasePath').disabled = false
		if (code.toString() == '0') {
			let pin = document.getElementById('bashOutput1')
			pin.innerText += decoder.write(`done...`)
			pin.scrollTop = pin.scrollHeight
		} else {
			$('#debugMessages').text('Something went wrong... FUCK').css('color', 'red')
		}

	})
}, false)

