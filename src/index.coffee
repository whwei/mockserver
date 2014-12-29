args = require('optimist').argv
colors = require 'colors'
fs = require 'fs'
path = require 'path'
MockServer = require('./mockserver').MockServer

bootstrap = ->

    dir = path.join process.cwd(), (args.data || args.d ? '/data.js')

    if not fs.existsSync dir and not args.data and not args.d
        dir = path.join process.cwd(), '/data.json'

    if not fs.existsSync dir
        console.log "invalid data path: #{dir}".red
        return;

    server = new MockServer dir

    process.on 'SIGINT', ()->
        server.close()
        console.log "server stopped.".red
        process.exit()


module.exports = bootstrap
