MockServer = require('../app/mockserver').MockServer
http = require 'http'
hostile = require 'hostile'
supertest = require 'supertest'

describe 'MockServer', ->
    describe '#createServer', ->
        server = null;

        beforeEach ->
            server = new MockServer '../test/fixture/data.json', '../test/fixture/option.json'

        afterEach ->
            server.close()

        it 'should create a instance of http.Server',  ->
            expect server.server()
                .to.be.instanceof http.Server


        it 'accept mock data and a optional option', ->
            try
                expect new MockServer()
                .to.throw 'IllegallArgument: mock data requried'
            catch e





            # it 'should store maps in MockServer.maps'


            # it 'should extend option with defaultOption'
            #   server


            # describe '#addHosts', ->
            #   server = null;

            #   it 'should add rule to hosts file', (cb)->
            #     hostile.get false, (err, lines)->
            #       expect err
            #         .to.be.null

            #       expect(lines.some (line) -> ~line.indexOf 'example.com').to.be.false

            #       cb()
