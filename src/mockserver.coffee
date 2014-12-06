http = require 'http'
_ = require 'underscore'
hostz = require './hostz'

express = require 'express'


MockServer =
    maps: []

defaultOpt =
    port: 80
    cors: true
    log: false


corsMiddleWare = (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Method', 'GET, PUT, POST, DELETE'
    res.header 'Access-Control-Allow-Header', 'Content-Type'

    next()

class MockServer
    constructor: (dataPath, optionPath) ->

        if !dataPath
            throw new Error 'IllegallArgument: mock data requried'

        # read mock data
        mockData = {};
        try
            mockData = require dataPath
        catch e
            throw new Error 'IllegallArgument: invalid mock data path'

        # read option file
        option = {}
        if optionPath
            try
                option = require optionPath
            catch e
                console.error 'fail to load option file, use default option'

        @_option = _.extend(defaultOpt, option)

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

        # backup hosts
        @backupHosts()

        # modify hosts
        @addHosts()

        @_server = @_app.listen @_option.port, =>
            console.log "listening at port: #{@_option.port}"


    server: ->
        return @_server;



    close: ->
        if @_server
            @_server.close =>
                console.log "server at port #{@_option.port} closed."


        @restoreHosts()



    # add a map to the server
    addMap: (map) ->
        if !map
            throw new Error 'map is required'

        method = map['method'] ? 'get'
        path = map['path'] ? '/'
        response = map['response']

        @_app[method] path, (req, res) ->
            res.json response


    # add hosts
    addHosts: ->
        target = @_option.domain;

        try
            hostz.add '127.0.0.1', target
            console.log "'127.0.0.1 #{target}' added successfully."
        catch e
            console.log e

    # backup hosts
    backupHosts: ->
        hostz.backup()
        console.log 'backup hosts!'

    # restore hosts
    restoreHosts: ->
        hostz.restore()
        console.log 'restore hosts!'



exports.MockServer = MockServer
