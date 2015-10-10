http    = require 'http'
_       = require 'underscore'
url     = require 'url'
fs      = require 'fs'
path    = require 'path'
colors  = require 'colors'
express = require 'express'
proxy   = require 'express-http-proxy'
cors    = require 'cors'

defaultOpt =
    port: 9222
    log: true

wrapModule = (def, md) ->
    return "(function(exports, require, module){#{def}})(#{md}.exports, require, #{md})"


log = console.log.bind(console)

noop = () -> {}

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

                wrappedDef = wrapModule(fs.readFileSync(dataPath, {encoding: 'utf8'}), 'md')

                eval wrappedDef

                mockData = md.exports

        catch
            console.error "fail to load data: #{dataPath}".red


        # merge option
        @_option = {}
        @_option = _.extend(@_option, defaultOpt, option)
        option = @_option

        if not @_option.log
            log = noop


        # init server
        @_app = express()

        # PROXY
        if mockData.proxy
            @_app.use '/', proxy mockData.proxy, {
                forwardPath: (req, res) =>
                    return url.parse(req.url).path
                intercept: (rsp, data, req, res, callback) =>
                    if mockData.cors
                        headers = req.get('Access-Control-Request-Headers')
                        if (headers)
                            res.set('Access-Control-Allow-Headers', headers)
                        res.set('Access-Control-Allow-Methods', 'GET, POST, PUT')
                        res.set('Access-Control-Allow-Origin', mockData.cors.origin || '*')

                    callback(null, data)

            }
        else
            # cors
            if mockData.cors
                @_app.use cors({
                    origin: mockData.cors.origin || '*',
                    methods: ['GET','POST','PUT'],
                    allowedHeaders: mockData.cors.allowedHeaders
                })

            # route
            if !mockData.routes
                throw new Error 'Invalid mapping data'

            mockData.routes.forEach (route) =>
                @addRoute route


        # start server
        @_server = @_app.listen option.port, =>
            log "Starting up server at port: #{@_option.port}".yellow
            log 'Hit CTRL-C to stop the server'.yellow


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
        status = route['status'] ? 200
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
            log '[%s] "%s %s" "%s"', (new Date).toLocaleString(), req.method.yellow, req.url.yellow, req.headers['user-agent'].cyan.underline

            respond = (result) ->
                if dataType is 'jsonp' and cb
                    res.setHeader 'Content-Type', 'application/javascript'
                    res.status(status).end "#{cb}&&#{cb}(#{JSON.stringify(result)})"
                else
                    res.status(status).json result

            if delay and typeof delay is 'number'
                setTimeout ->
                    respond result
                ,
                delay
            else
                respond result



module.exports = MockServer
