hostz = require '../app/hostz'
hostile = require 'hostile'


describe 'hostz', ->
    # it '#add should add "ip domain" to hosts file', (cb) ->
    it '#get should return current hosts file content', () ->
        hostile.get false, (err, content) ->
            console.log content

        lines = hostz.get()

        currentHostsContent = [['127.0.0.1', 'localhost'],
                               ['255.255.255.255', 'broadcasthost'],
                               ['::1', 'localhost', ''],
                               ['fe80::1%lo0', 'localhost'],
                               ['185.31.17.184', 'github.global.ssl.fastly.net'],
                               ['185.31.16.184', 'github-camo.global.ssl.fastly.net']]

        expect lines
        .to.eql currentHostsContent
