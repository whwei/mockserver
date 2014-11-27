MockServer = require('../app/mockserver').MockServer
http = require 'http'
fs = require 'fs'
hostile = require 'hostile'
request = require 'supertest'

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


    describe 'server#backupHosts', ->
        it 'should backup hosts file', () ->
            exist = 0;
            try
                fs.readFileSync "#{hostile.HOSTS}.backup", 'utf-8'
            catch e
                exist = 1

            expect exist
                .to.eql 1

            original = 'original'
            original = fs.readFileSync hostile.HOSTS, 'utf-8'

            server = new MockServer '../test/fixture/data.json', '../test/fixture/option.json'


            backup = 'backup'
            try
                backup = fs.readFileSync "#{hostile.HOSTS}.backup", 'utf-8'
            catch e
                exist = 2

            expect exist
                .to.eql 1

            expect original
                .to.eql backup

            server.close()


    describe 'server#restoreHosts', ->
        it 'should backup hosts file', () ->
            exist = 0;
            try
                fs.readFileSync "#{hostile.HOSTS}.backup", 'utf-8'
            catch e
                exist = 1

            expect exist
                .to.eql 1

            original = 'original'
            original = fs.readFileSync hostile.HOSTS, 'utf-8'

            server = new MockServer '../test/fixture/data.json', '../test/fixture/option.json'
            server.restoreHosts()

            current = 'backup'
            try
                current = fs.readFileSync hostile.HOSTS, 'utf-8'
            catch e
                exist = 2

            expect exist
                .to.eql 1

            expect original
                .to.eql current

            server.close()


    describe 'server#addHosts', ->
        server = null;

        beforeEach ->
            server = new MockServer '../test/fixture/data.json', '../test/fixture/option.json'

        afterEach ->
            server.close()

        it 'should add rule to hosts file', () ->
            hostsContent = fs.readFileSync hostile.HOSTS, 'utf-8'

            expect hostsContent
                .to.contain '127.0.0.1 api.interfacedomain.com'



    describe 'server#addHosts', ->
        server = null;

        beforeEach ->
            server = new MockServer '../test/fixture/data.json', '../test/fixture/option.json'

        afterEach ->
            server.close()

        it 'should add rule to hosts file', () ->
            hostsContent = fs.readFileSync hostile.HOSTS, 'utf-8'

            expect hostsContent
            .to.contain '127.0.0.1 api.interfacedomain.com'



    describe 'set up a local server', ->
        server = null;

        beforeEach ->
            server = new MockServer '../test/fixture/data.json', '../test/fixture/option.json'

        afterEach ->
            server.close()

        it 'respond users when request /people', (cb) ->
            request server.server()
                .get '/people'
                .expect 200
                .expect (res) ->
                    if !res.body or res.body.length != 6
                        throw new Error 'unexpected response data'
                .end(cb)

        it 'respond posts when request /pots', (cb) ->
            request server.server()
                .get '/posts'
                .expect 200
                .expect (res) ->
                    if !res.body or res.body.length != 8
                        throw new Error 'unexpected response data'

                    exists = res.body.some (post) ->
                        post.title is "Post Title 2" and post.date is 1416962762128 and post.author is '000001' and post.content is 'balblablalbalblab'

                    if not exists
                        throw new Error 'post data missing'
                .end(cb)

        it 'should intercept the request and respond corresponding mock data', (cb) ->
            localRequest = request 'http://api.interfacedomain.com'

            localRequest.get '/people'
                .expect 200, (err) ->
                    expect err
                        .to.be.null()
                    cb()
