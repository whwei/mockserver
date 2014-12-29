var MockServer, args, bootstrap, colors, fs, path;

args = require('optimist').argv;

colors = require('colors');

fs = require('fs');

path = require('path');

MockServer = require('./mockserver').MockServer;

bootstrap = function() {
  var dir, server, _ref;
  dir = path.join(process.cwd(), (_ref = args.data || args.d) != null ? _ref : '/data.js');
  if (!fs.existsSync(dir && !args.data && !args.d)) {
    dir = path.join(process.cwd(), '/data.json');
  }
  if (!fs.existsSync(dir)) {
    console.log(("invalid data path: " + dir).red);
    return;
  }
  server = new MockServer(dir);
  return process.on('SIGINT', function() {
    server.close();
    console.log("server stopped.".red);
    return process.exit();
  });
};

module.exports = bootstrap;
