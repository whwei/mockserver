fs = require 'fs'



COMMENT_REG = /\s*#.*/

isWindows = process.platform is 'win32'

hosts = if isWindows then 'C:Windows/System32/drivers/etc/hosts' else '/etc/hosts'

hostz =
    backup: ->
        content = fs.readFileSync hosts
        fs.writeFileSync "#{hosts}.backup", content



    restore: ->
        if fs.existsSync "#{hosts}.backup"
            backup = fs.readFileSync "#{hosts}.backup"
            fs.writeFileSync hosts, backup
            fs.unlink "#{hosts}.backup"
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
            splitLine = line.map (item) ->
                return item.trim()
            return splitLine[0] is ip and splitLine[1] is domain

        lines.push [ip, domain] if not exist

        # write to hosts file
        content =  lines.reduce (data, line) ->
            return "#{data}\n#{line.join(' ')}";
        ,
            ''
        fs.writeFileSync hosts, content

        return exist

module.exports = hostz
