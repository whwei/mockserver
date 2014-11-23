fs = require 'fs'



COMMENT_REG = /\s*#.*/

isWindows = process.platform is 'win32'

hosts = if isWindows then 'C:Windows/System32/drivers/etc/hosts' else '/etc/hosts'

hostz =
    backup: ->
        r = fs.createReadStream hosts
        w = fs.createWriteStream "#{hosts}.backup",
            flags: 'w',
            mode: 0o666

        r.pipe w


    restore: ->
        if fs.existsSync "#{hosts}.backup" is true
            r = fs.createReadStream "#{hosts}.backup"
            w = fs.createWriteStream hosts,
                flags: 'w',
                mode: 0o666

            r.pipe w
            return true
        else
            return false


    get: ->
        lines = []

        content = fs.readFileSync(hosts, 'utf-8').split /\r?\n/

        content.forEach (line) ->
            if line and not COMMENT_REG.test line
                lines.push line.split /\s+/

        return lines


    add: (ip, domain) ->
        lines = hostz.get()

        exist = lines.some (line) ->
            splitLine = line.trim().split /\s+/
            return splitLine[0] is ip and splitLine[1] is domain

        lines.push "#{ip} #{domain}" if not exist

        return exist


module.exports = hostz
