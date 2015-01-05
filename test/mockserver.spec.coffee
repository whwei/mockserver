MockServer = require('../src/mockserver').MockServer
http = require 'http'
fs = require 'fs'
hostile = require 'hostile'

describe 'MockServer', ->
    describe '#createServer', ->
        server = null;

        beforeEach () ->
            server = new MockServer '../test/fixture/data.json', {modifyHosts: true, log: false}

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
        it 'should not modify the hosts file when param modifyHosts is false', (cb) ->
            anotherServer = null

            original = 'original'
            original = fs.readFileSync hostile.HOSTS, 'utf-8'
            try
                anotherServer = new MockServer '../test/fixture/data.js', {modifyHosts: false, log: false}
            catch e
                console.log e

            current = 'backup'
            current = fs.readFileSync hostile.HOSTS, 'utf-8'

            expect original
            .to.eql current

            if anotherServer
                anotherServer.close cb



        it 'should create a server at port specified by param port', (cb) ->
            serverAtCustomPort = null

            try
                serverAtCustomPort = new MockServer '../test/fixture/data.js', { port: 9090, log: false }
            catch e
                console.log e

            expect serverAtCustomPort.server().address().port
            .to.eql 9090

            if serverAtCustomPort
                serverAtCustomPort.close cb



describe 'server', ->
    describe '#backupHosts', ->
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

            server = new MockServer '../test/fixture/data.json', {modifyHosts: true, log: false}


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


    describe '#restoreHosts', ->
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

            server = new MockServer '../test/fixture/data.json', {modifyHosts: true, log: false}
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


    describe '#addHosts', ->
        server = null;

        beforeEach ->
            server = new MockServer '../test/fixture/data.json', {modifyHosts: true, log: false}

        afterEach ->
            server.close()

        it 'should add rule to hosts file', () ->
            hostsContent = fs.readFileSync hostile.HOSTS, 'utf-8'

            expect hostsContent
                .to.contain '127.0.0.1 api.interfacedomain.com'



    describe '#addHosts', ->
        server = null;

        beforeEach ->
            server = new MockServer '../test/fixture/data.json', {modifyHosts: true, log: false}

        afterEach ->
            server.close()

        it 'should add rule to hosts file', () ->
            hostsContent = fs.readFileSync hostile.HOSTS, 'utf-8'

            expect hostsContent
            .to.contain '127.0.0.1 api.interfacedomain.com'


    describe 'should set up a local server', ->
        server = null;

        beforeEach ->
            server = new MockServer '../test/fixture/data.json', { modifyHosts: true, log: false }

        afterEach ->
            server.close()


        it 'intercept the request and respond corresponding mock data', (cb) ->
            localRequest = request 'http://api.interfacedomain.com'

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


        it 'should support CORS', (cb) ->
            localRequest = request 'http://api.interfacedomain.com'

            localRequest.post '/people'
                .expect 200
                .expect (res) ->
                    if res.headers['access-control-allow-origin'] isnt '*'
                        throw new Error 'access-control-allow-origin not set'

                    if res.headers['access-control-allow-method'] isnt 'GET, PUT, POST, DELETE'
                        throw new Error 'access-control-allow-method not set'

                    if res.header['access-control-allow-header'] isnt 'Content-Type'
                        throw new Error 'access-control-allow-header not set'

                .end cb


        it 'should support jsonp', (cb) ->
            localRequest = request 'http://api.interfacedomain.com'

            localRequest.get '/people_jsonp'
            .query { callback: 'cbFn'}
            .expect 200
            .expect (res) ->
                if res.headers['content-type'] isnt 'application/javascript'
                    throw new Error 'Content-type not application/javascript'

            .end cb


    describe 'should allow dynamic response', ->
        server = null

        beforeEach ->
            server = new MockServer '../test/fixture/data.js', {modifyHosts: true, log: false }

        afterEach ->
            server.close()

        it 'should receive a data.js file',  ->
            localRequest = request 'http://api.interfacedomain.com'

            localRequest.get '/people'
            .expect 200
            .expect { id: 1, name: 'people 1'}


        it 'should respond dynamically',  ->
            localRequest = request 'http://api.interfacedomain.com'

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
            localRequest = request 'http://api.interfacedomain.com'

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
            localRequest = request 'http://api.interfacedomain.com'

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


