http = require 'http'
_ = require 'underscore'
url = require 'url'
fs = require 'fs'
path = require 'path'
colors = require 'colors'
express = require 'express'

defaultOpt =
    port: 9222
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


        # start server
        @_server = @_app.listen option.port, =>
            console.log "Starting up server at port: #{@_option.port}".yellow
            console.log 'Hit CTRL-C to stop the server'.yellow


        # remember sockets
        @_sockets = {}
        socketId = 0
        @_server.on 'connection', (socket) =>
            id = socketId++
            @_sockets[id] = socket

            socket.on 'close', =>
                delete @_sockets[id]


    server: ->
        return @_server;


    # close server
    close: (cb)->
        # destroy sockets manually so that we can close server immediately
        for socket of @_sockets
            @_sockets[socket] && @_sockets[socket].destroy()

        if @_server
            @_server.close cb



    # add a route to the express app
    addRoute: (route) ->
        if !route then return

        method = route['method'] ? 'get'
        apiPath = route['path'] ? '/'
        response = route['response']
        dataType = route['type']
        delay = route['delay'] or 0

        @_app[method] apiPath, (req, res) ->

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



module.exports = MockServer
