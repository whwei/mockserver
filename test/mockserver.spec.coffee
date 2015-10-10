MockServer = require('../src/mockserver')
http = require 'http'
fs = require 'fs'
path = require 'path'

mockJS = path.join __dirname, '../test/fixture/data.js'
mockJSON = path.join __dirname, '../test/fixture/data.json'
proxyMockJSON = path.join __dirname, '../test/fixture/proxy.json'

defaultOption =
    log: false

describe 'MockServer', ->
    describe '#createServer', ->
        server = null;

        beforeEach () ->
            server = new MockServer mockJSON, defaultOption

        afterEach () ->
            server.close()

        it 'should create a instance of http.Server',  ->
            expect server.server()
                .to.be.instanceof http.Server



        it 'accept mock data and a optional option', (cb) ->
            try
                expect new MockServer()
                .to.throw 'IllegallArgument: mock data required'
            catch e

            cb()

    describe '#createServer option', ->

        it 'should create a server at port specified by param `port`', (cb) ->
            serverAtCustomPort = null

            try
                serverAtCustomPort = new MockServer mockJS, { port: 9090, log: false }
            catch e
                console.log e

            expect serverAtCustomPort.server().address().port
            .to.eql 9090

            if serverAtCustomPort
                serverAtCustomPort.close cb



describe 'server', ->

    describe 'should set up a local server', ->
        server = null;

        beforeEach ->
            server = new MockServer mockJSON, defaultOption

        afterEach ->
            server.close()


        it 'intercept the request and respond corresponding mock data', (cb) ->
            localRequest = request 'http://localhost:9222'

            localRequest.get '/people'
            .expect 200
            .end cb


        it 'respond users when get /people', (cb) ->
            request server.server()
                .get '/people'
                .expect 200
                .expect (res) ->
                    if !res.body or res.body.length != 6
                        throw new Error 'unexpected response data'
                .end cb


        it 'respond posts when get /posts', (cb) ->
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
                .end cb

        it 'allow user to specify http status', (cb) ->
            request server.server()
                .get '/tags'
                .expect 500
                .expect (res) ->
                    if !res.body
                        throw new Error 'unexpected response'
                .end cb


        it 'should support CORS', (cb) ->
            localRequest = request 'http://localhost:9222'

            localRequest.get '/people'
                .expect 200
                .expect (res) ->
                    if res.headers['access-control-allow-origin'] isnt '*'
                        throw new Error 'access-control-allow-origin not set'

                .end cb


        it 'should support preflighted CORS request', (cb) ->
            localRequest = request 'http://localhost:9222'

            localRequest.options '/people'
                .set 'X-Request-Header', 'XXX'
                .expect 204
                .expect (res) ->
                    if res.headers['access-control-allow-origin'] isnt '*'
                        throw new Error 'access-control-allow-origin not set'

                    if not res.headers['access-control-allow-methods']
                        throw new Error 'access-control-allow-methods not set'

                .end cb

        it 'should support jsonp', (cb) ->
            localRequest = request 'http://localhost:9222'

            localRequest.get '/people_jsonp'
            .query { callback: 'cbFn'}
            .expect 200
            .expect (res) ->
                if res.headers['content-type'] isnt 'application/javascript'
                    throw new Error 'Content-type not application/javascript'

            .end cb


    describe 'should support proxy', ->
        server = null

        beforeEach ->
            server = new MockServer proxyMockJSON, { log: false }

        afterEach ->
            server.close()

        it 'should add cors header to response from target api', (cb) ->
            this.timeout 10000

            proxyRequest = request 'http://localhost:9222'

            proxyRequest.get '/users/octocat'
                .expect 200
                .expect (res) ->
                    if res.headers['access-control-allow-origin'] isnt 'http://localhost:8080'
                        throw new Error 'Access-Control-Allow-Origin is not overrided by proxy'
                .end cb


    describe 'should allow dynamic response', ->
        server = null

        beforeEach ->
            server = new MockServer mockJS, { log: false }

        afterEach ->
            server.close()

        it 'should receive a data.js file',  ->
            localRequest = request 'http://localhost:9222'

            localRequest.get '/people'
            .expect 200
            .expect { id: 1, name: 'people 1'}


        it 'should respond dynamically',  ->
            localRequest = request 'http://localhost:9222'

            localRequest.get '/people'
            .expect 200
            .expect { id: 1, name: 'people 1'}

            localRequest.get '/people'
            .expect 200
            .expect { id: 2, name: 'people 2'}

            localRequest.get '/people'
            .expect 200
            .expect { id: 3, name: 'people 3'}


        it 'should supoort dynamic jsonp request', () ->
            localRequest = request 'http://localhost:9222'

            localRequest.get '/people_jsonp'
            .query { callback: 'cbFn'}
            .expect 200
            .expect (res) ->
                if res.headers['content-type'] isnt 'application/javascript'
                    throw new Error 'Content-type not application/javascript'

                if res.body.id isnt 1 or res.body.name isnt 'people 1'
                    throw new Error 'response content error: ' + JSON.stringify(res.body)


            localRequest.get '/people_jsonp'
            .query { callback: 'cbFn'}
            .expect 200
            .expect (res) ->
                if res.headers['content-type'] isnt 'application/javascript'
                    throw new Error 'Content-type not application/javascript'

                if res.body.id isnt 2 or res.body.name isnt 'people 2'
                    throw new Error 'response content error: ' + JSON.stringify(res.body)



        it 'should respond by query',  ->
            localRequest = request 'http://localhost:9222'

            localRequest.get '/people'
            .query('team', 'rockets')
            .expect 200
            .expect [
                {
                    number: 11,
                    name: 'Yao Ming'
                },
                {
                    number: 1,
                    name: 'Tracy McGrady'
                }
            ]

            localRequest.get '/people'
            .query('team', 'lakers')
            .expect 200
            .expect [
                {
                    number: 24,
                    name: 'Kobe Bryant'
                },
                {
                    number: 0,
                    name: 'Nick Young'
                },
                {
                    number: 17,
                    name: 'Jeremy Lin'
                }
            ]

            localRequest.get '/people'
            .expect 200
            .expect []
