http = require 'http'
fs = require 'fs'
path = require 'path'
_ = require 'underscore'

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

  MockServer.option = _.extend(defaultOpt, option)


  # init server 
  app = express()

  # route
  if (!mockData.maps) throw new Error 'Invalid mapping data'

  mockData.maps.forEach (m, i) ->
    MockServer.addMap m

  return app.listen MockServer.port
  

# add a map to the server
MockServer.addMap = (map) ->
  if !map 
    throw new Error 'map is required'

  


exports.MockServer = MockServer