args = require('optimist').argv
colors = require 'colors'
fs = require 'fs'
path = require 'path'
MockServer = require('./mockserver').MockServer


bootstrap = ->

    opt = {}

    dir = path.join process.cwd(), (args.data || args.d ? '/data.js')

    opt.port = args.port or args.p or 80
    opt.modifyHosts = args.hosts or args.h
    if opt.modifyHosts then opt.port = 80

    if not fs.existsSync dir
        dir = path.join process.cwd(), '/data.json'

    if not fs.existsSync dir
        console.log "invalid data path: #{dir}".red
        return;

    server = new MockServer dir, opt

    restart = ->
        if server then server.close()

        server = new MockServer dir, opt


    fs.watchFile dir, restart

    process.on 'SIGINT', ->
        server.close()
        fs.unwatchFile dir, restart

        console.log "server stopped.".red
        process.exit()


module.exports = bootstrap
