ms = require('../app/index').MockServer
http = require 'http'

describe 'MockServer', ->
  
  describe '#createServer', ->
    server = null;

    beforeEach ->
      server = ms.createServer '../test/fixture/data.json', '../test/fixture/option.json'

    it 'which should be a instance of http.Server', ->
      expect server
        .to.be.instanceof http.Server

    it 'accept mock data and a optional option', ->
      try
        testServer = ms.createServer()
      catch e
        expect e.message
          .to.eql 'IllegallArgument: mock data requried'
      