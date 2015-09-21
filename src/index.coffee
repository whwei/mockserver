args = require('optimist').argv
colors = require 'colors'
fs = require 'fs'
path = require 'path'
MockServer = require('./mockserver')


bootstrap = ->

    opt = {}

    dir = path.join process.cwd(), (args.data || args.d ? '/data.js')

    if args.port or args.p then opt.port = args.port

    if not fs.existsSync dir
        dir = path.join process.cwd(), '/data.json'

    if not fs.existsSync dir
        console.log "invalid data path: #{dir}".red
        return;

    server = new MockServer dir, opt

    restart = ->
        if server
            console.log 'mock data update: restarting server...'
            server.close ->
                server = new MockServer dir, opt


    fs.watchFile dir, restart

    process.on 'SIGINT', ->
        server.close()
        fs.unwatchFile dir, restart

        console.log "server stopped.".red
        process.exit()


module.exports = bootstrap
