var COMMENT_REG, fs, hosts, hostz, isWindows;

fs = require('fs');

COMMENT_REG = /\s*#.*/;

isWindows = process.platform === 'win32';

hosts = isWindows ? 'C:/Windows/System32/drivers/etc/hosts' : '/etc/hosts';

hostz = {
  backup: function() {
    var content;
    content = fs.readFileSync(hosts);
    return fs.writeFileSync("" + hosts + ".backup", content);
  },
  restore: function() {
    var backup;
    if (fs.existsSync("" + hosts + ".backup")) {
      backup = fs.readFileSync("" + hosts + ".backup");
      fs.writeFileSync(hosts, backup);
      fs.unlinkSync("" + hosts + ".backup");
      return true;
    } else {
      return false;
    }
  },
  get: function() {
    var content, lines;
    lines = [];
    content = fs.readFileSync(hosts, 'utf-8').split(/\r?\n/);
    content.forEach(function(line) {
      if (line && !COMMENT_REG.test(line)) {
        return lines.push(line.split(/\s+/));
      }
    });
    return lines;
  },
  add: function(ip, domain) {
    var content, exist, lines;
    lines = hostz.get();
    exist = lines.some(function(line) {
      var splitLine;
      splitLine = line.map(function(item) {
        return item.trim();
      });
      return splitLine[0] === ip && splitLine[1] === domain;
    });
    if (!exist) {
      lines.push([ip, domain]);
    }
    content = lines.reduce(function(data, line) {
      return "" + data + "\n" + (line.join(' '));
    }, '');
    fs.writeFileSync(hosts, content);
    return exist;
  }
};

module.exports = hostz;
