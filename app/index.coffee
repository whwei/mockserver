http = require 'http'
fs = require 'fs'
path = require 'path'
_ = require 'underscore'
hostile = require 'hostile'

express = require 'express'


MockServer =
    maps: []

defaultOpt =
    port: 8989


MockServer.createServer = (dataPath, optionPath) ->

    if !dataPath
        throw new Error 'IllegallArgument: mock data requried'

    # read mock data
    mockData = {};
    try
        dataPath = path.resolve __dirname, dataPath
        mockData = fs.readFileSync dataPath
        mockData = JSON.parse mockData
    catch e
        throw new Error 'IllegallArgument: invalid mock data path'

    # read option file
    option = {}
    if optionPath
        try
            optionPath = path.resolve __dirname, optionPath
            option = fs.readFileSync optionPath
            option = JSON.parse option
        catch e
            console.error 'fail to load option file, use default option'

    MockServer.option = _.extend(defaultOpt, option)


    # init server
    this.app = express()

    # route
    if !mockData.maps
        throw new Error 'Invalid mapping data'

    mockData.maps.forEach (map) ->
        MockServer.addMap map

    # modify hosts
    MockServer.addHosts()

    return this.app.listen MockServer.port, ->
        "listening at port: #{MockServer.option.port}"


MockServer.close = ->
    MockServer.removeHosts()
    console.log "server at port #{MockServer.option.port} closed."


# add a map to the server
MockServer.addMap = (map) ->
    if !map
        throw new Error 'map is required'

    method = map['method'] || 'get'
    url = map['url'] || '/'
    response = map['response']

    this.app[method] url, (req, res) ->
        res.json response


# modify hosts
MockServer.addHosts = ->
    target = MockServer.option.domain;

    hostile.set '127.0.0.1', target, (e)->
        if e
            console.error e
        else
            console.log "set #{target} successfully."


MockServer.removeHosts = ->
    target = MockServer.option.domain;

    hostile.remove '127.0.0.1', target, (e)->
        if e
            console.error e
        else
            console.log "remove #{target} successfully."



exports.MockServer = MockServer
