fs = require 'fs'

isWindows = process.platform is 'win32'

hosts = if isWindows then 'C:Windows/System32/drivers/etc/hosts' else '/etc/hosts'

hostz = 
  get: ->
    lines = []
    
    content = fs.readFileSync(hosts, 'utf-8').split /\r?\n/ 

    content.forEach (line) -> 
      if line
        lines.push line.split /\s+/

    return lines
    
  add: (ip, domain) ->
    lines = hostz.get()

    exist = lines.some (line) ->
      splitLine = line.split /\s+/
      return splitLine[0] is ip and splitLine[1] is domain

    lines.push "#{ip} #{domain}" if not exist

    return exist


module.exports = hostz