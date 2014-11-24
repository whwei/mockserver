hostz = require '../app/hostz'
hostile = require 'hostile'
fs = require 'fs'

describe 'hostz', ->

    beforeEach ->
        hostz.backup()

    afterEach ->
        hostz.restore()


    it '#backup should create a hosts backup', () ->
        backup = "#{hostile.HOSTS}.backup"


        hosts = fs.readFileSync hostile.HOSTS, 'utf-8'

        expect hosts
            .not.to.be.null()

        try
            fs.unlinkSync backup
        catch e


        exists = 0
        # no backup file exists
        try
            fs.readFileSync backup, 'utf-8'
        catch e
            exists = 1 # not exist

        expect exists
            .to.eql 1

        hostz.backup()

        # no backup file exists
        try
            fs.readFileSync backup, 'utf-8'
        catch e
            exists = 2

        expect exists
            .to.eql 1

        try
            fs.unlinkSync backup
        catch e


    it '#restore should restore from the hosts.backup file', () ->

        hostz.backup()

        expect fs.existsSync "#{hostile.HOSTS}.backup"
            .to.be.true()

        original = fs.readFileSync hostile.HOSTS

        fs.writeFileSync hostile.HOSTS, 'empty'
        modified = fs.readFileSync hostile.HOSTS

        expect original
            .not.to.eql modified

        hostz.restore()

        restored = fs.readFileSync hostile.HOSTS
        expect original
            .to.eql restored


    it '#get should return current hosts file content', () ->
        hostile.get false, (err, content) ->

            lines = hostz.get()

            currentHostsContent = content

            expect lines
            .to.eql currentHostsContent



    it '#add should add "#{ip} #{domain}" pair to the hosts file', () ->

        original = hostz.get()
        include = original.some (line) ->
            return line[0] is '123.123.123.123' and line[1] is 'example.com'

        expect include
            .to.be.false()

        hostz.add '123.123.123.123', 'example.com'

        current = hostz.get()
        include = current.some (line) ->
            return line[0] is '123.123.123.123' and line[1] is 'example.com'

        expect include
            .to.be.true()


