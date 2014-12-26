args = require('optimist').argv
colors = require 'colors'
MockServer = require('./mockserver').MockServer

bootstrap = ->

    opt =
        data: process.cwd() + (args.data || args.d ? '/data.json')
        option: process.cwd() + (args.option || args.o ? '/option.json')


    server = new MockServer opt.data, opt.option

    process.on 'SIGINT', ()->
        server.close()
        console.log "server stopped.".red
        process.exit()


module.exports = bootstrap
