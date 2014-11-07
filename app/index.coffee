http = require 'http'
fs = require 'fs'
path = require 'path'
_ = require 'underscore'

express = require 'express'


MockServer = {}
defaultOpt = 
  port: 8989


MockServer.createServer = (dataPath, optionPath) ->

  if !dataPath
    throw new Error 'IllegallArgument: mock data requried'

  mockData = {};
  try
    dataPath = path.resolve __dirname, dataPath
    mockData = fs.readFileSync dataPath
  catch e
    throw new Error 'IllegallArgument: invalid mock data path'

  option = {}
  if optionPath
    try
      optionPath = path.resolve __dirname, optionPath
      option = fs.readFileSync optionPath
      option = JSON.parse option
    catch e

  MockServer.option = _.extend(defaultOpt, option)


  app = express()

  return app.listen MockServer.port
  
  

exports.MockServer = MockServer