MockServer = require('../app/mockserver').MockServer
http = require 'http'
fs = require 'fs'
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
                .to.contain '127.0.0.1 example.com'



    describe 'server#addHosts', ->
        server = null;

        beforeEach ->
            server = new MockServer '../test/fixture/data.json', '../test/fixture/option.json'

        afterEach ->
            server.close()

        it 'should add rule to hosts file', () ->
            hostsContent = fs.readFileSync hostile.HOSTS, 'utf-8'

            expect hostsContent
            .to.contain '127.0.0.1 example.com'
