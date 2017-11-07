const { spawn } = require('child_process')

//exec('ls -al', (error, stdout, stderr) => {
//    if (error) {
//        console.error(error)
//        return
//    } else {
//        console.log(stdout)
//    }
//})


const script = spawn('ls', ['-1'])
script.stdout.on('data', (data) => {
    console.log(data.toString())
})
script.stderr.on('data', (data) => {
    console.log(data)
})
script.on('exit', (code) => {
    console.log(code)
})
