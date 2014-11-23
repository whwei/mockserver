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
        result = hostz.restore()
        console.log "restore: " + result
        if result is true
            hostsContent = fs.readFileSync hostile.HOSTS
            backupContent = fs.readFileSync "#{hostile.HOSTS}.backup"

            expect hostsContent
                .to.be backupContent

    it '#get should return current hosts file content', (cb) ->
        hostile.get false, (err, content) ->

            lines = hostz.get()

            currentHostsContent = content

            expect lines
            .to.eql currentHostsContent

            cb()


    it '#add should add "#{ip} #{domain}" pair to the hosts file', ()->

        original = hostz.get()

        expect original
            .not.include [['123.123.123.123'], ['example.com']]



