http = require 'http'
_ = require 'underscore'
hostz = require './hostz'
url = require 'url'
fs = require 'fs'
path = require 'path'
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


wrapModule = (def, md) ->
    return "(function(exports, require, module){#{def}})(#{md}.exports, require, #{md})"


class MockServer
    constructor: (dataPath, option) ->

        if !dataPath
            throw new Error 'mock data required'
        console.log dataPath
        # read mock data
        mockData = {};
        try
            type = path.extname dataPath

            if type is '.json'
                strData = fs.readFileSync(dataPath, {encoding: 'utf8'}).replace(/\n|\r/g, '')

                mockData = JSON.parse strData
            else if type is '.js'
                md = {
                    exports: {}
                }

                wrappedDef = wrapModule(fs.readFileSync(dataPath, {encoding: 'utf8'}), 'md').replace(/\n|\r/g, '')

                eval wrappedDef

                mockData = md.exports

        catch
            console.error "fail to load data: #{dataPath}".red


        # merge option
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
        if !mockData.routes
            throw new Error 'Invalid mapping data'

        mockData.routes.forEach (route) =>
            @addRoute route


        # modify hosts file
        if @_option.modifyHosts
            @backupHosts()

            @addHosts()


        # start server
        @_server = @_app.listen option.port, =>
            console.log "Starting up server at port: #{@_option.port}".yellow
            console.log 'Hit CTRL-C to stop the server'.yellow

    server: ->
        return @_server;


    # close server, if the hosts file was modified, restore it
    close: (cb)->
        if @_server
            @_server.close cb

        if @_option.modifyHosts
            @restoreHosts()



    # add a route to the express app
    addRoute: (route) ->
        if !route then return

        method = route['method'] ? 'get'
        route = route['path'] ? '/'
        response = route['response']
        dataType = route['type']
        delay = route['delay'] or 0

        @_app[method] route, (req, res) ->
            query = url.parse(req.url, true).query
            cb = query['callback'] or query['cb']
            result = response

            # if response is a function, invoke it to get the result data
            if typeof response is 'function'
                result = response(req)

            # log req
            console.log '[%s] "%s %s" "%s"', (new Date).toLocaleString(), req.method.yellow, req.url.yellow, req.headers['user-agent'].cyan.underline

            respond = (result) ->
                if dataType is 'jsonp' and cb
                    res.setHeader 'Content-Type', 'application/javascript'
                    res.end "#{cb}&&#{cb}(#{JSON.stringify(result)})"
                else
                    res.json result

            if delay and typeof delay is 'number'
                setTimeout ->
                    respond result
                ,
                delay
            else
                respond result


    addHosts: ->
        target = @_option.domain;

        try
            hostz.add '127.0.0.1', target
        catch e
            console.log e


    backupHosts: ->
        hostz.backup()


    restoreHosts: ->
        hostz.restore()



exports.MockServer = MockServer
