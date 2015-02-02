http = require 'http'
_ = require 'underscore'
hostz = require './hostz'
url = require 'url'
colors = require 'colors'
express = require 'express'

defaultOpt =
    port: 80
    cors: true
    log: true


corsMiddleWare = (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Method', 'GET, PUT, POST, DELETE'
    res.header 'Access-Control-Allow-Header', 'Content-Type'

    next()

class MockServer
    constructor: (dataPath, option) ->

        if !dataPath
            throw new Error 'mock data requried'

        # read mock data
        mockData = {};
        try
            mockData = require dataPath
        catch
            console.error "fail to load data: #{dataPath}".red

        @_option = {}
        @_option.domain = mockData.domain or 'localhost'
        @_option.port = mockData.port or 80
        @_option = _.extend(@_option, defaultOpt, option)
        option = @_option

        originalLog = console.log
        console.log = () =>
            if @_option.log
                originalLog.apply console, arguments

        # init server
        @_app = express()

        # CORS
        if @_option.cors is true
            @_app.use corsMiddleWare

        # route
        if !mockData.maps
            throw new Error 'Invalid mapping data'

        mockData.maps.forEach (map) =>
            @addMap map

        # modify hosts file
        if @_option.modifyHosts
            # backup hosts
            @backupHosts()

            # modify hosts
            @addHosts()

        # start server
        @_server = @_app.listen option.port, =>
            console.log "Starting up server at port: #{@_option.domain}:#{@_option.port}".yellow
            console.log 'Hit CTRL-C to stop the server'.yellow

    server: ->
        return @_server;


    # close server, if hosts file is modified, restore it
    close: (cb)->
        if @_server
            @_server.close cb

        if @_option.modifyHosts
            @restoreHosts()



    # add a map to the server
    addMap: (map) ->
        if !map then return

        method = map['method'] ? 'get'
        path = map['path'] ? '/'
        response = map['response']
        dataType = map['type']

        @_app[method] path, (req, res) ->
            query = url.parse(req.url, true).query
            cb = query['callback'] or query['cb']
            result = response

            # if response is a function, invoke it to get the result data
            if typeof response is 'function'
                result = response(req)

            # log req
            console.log '[%s] "%s %s" "%s"', (new Date).toLocaleString(), req.method.yellow, req.url.yellow, req.headers['user-agent'].cyan.underline

            # support for jsonp
            if dataType is 'jsonp' and cb
                res.setHeader 'Content-Type', 'application/javascript'
                res.end "#{cb}&&#{cb}(#{JSON.stringify(result)})"
            else
                res.json result


    # add hosts
    addHosts: ->
        target = @_option.domain;

        try
            hostz.add '127.0.0.1', target
        catch e
            console.log e

    # backup hosts
    backupHosts: ->
        hostz.backup()

    # restore hosts
    restoreHosts: ->
        hostz.restore()



exports.MockServer = MockServer
