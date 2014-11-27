http = require 'http'
fs = require 'fs'
path = require 'path'
_ = require 'underscore'
hostz = require './hostz'

express = require 'express'


MockServer =
    maps: []

defaultOpt =
    port: 80


class MockServer
    constructor: (dataPath, optionPath) ->

        if !dataPath
            throw new Error 'IllegallArgument: mock data requried'

        # read mock data
        mockData = {};
        try
            mockData = require dataPath
        catch e
            console.log e
            throw new Error 'IllegallArgument: invalid mock data path'

        # read option file
        option = {}
        if optionPath
            try
                option = require optionPath
            catch e
                console.log e
                console.error 'fail to load option file, use default option'

        @_option = _.extend(defaultOpt, option)

        # init server
        @_app = express()

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

        # bind events
        signal = ['SIGTERM', 'SIGINT']
        signal.forEach (s) =>
            process.on s, =>
                @close()


    server: ->
        return @_server;



    close: ->
        if @_server
            @_server.close =>
                console.log "server at port #{@_option.port} closed."
                process.exit 0

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
