ms = require('../app/index').MockServer
http = require 'http'
hostile = require 'hostile'
supertest = require 'supertest'

describe 'MockServer', ->
    describe '#createServer', ->
        server = null;

        beforeEach ->
            server = ms.createServer '../test/fixture/data.json', '../test/fixture/option.json'

        afterEach ->
            ms.close()

        it 'should return a instance of http.Server', ->
            expect server
            .to.be.instanceof http.Server

        it 'accept mock data and a optional option', ->
            try
                expect ms.createServer()
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
