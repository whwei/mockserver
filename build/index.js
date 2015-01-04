var MockServer, args, bootstrap, colors, fs, path;

args = require('optimist').argv;

colors = require('colors');

fs = require('fs');

path = require('path');

MockServer = require('./mockserver').MockServer;

bootstrap = function() {
  var dir, modifyHosts, port, server, _ref;
  dir = path.join(process.cwd(), (_ref = args.data || args.d) != null ? _ref : '/data.js');
  port = args.port || args.p || 80;
  modifyHosts = args.hosts || args.h;
  if (modifyHosts) {

  }
  if (!fs.existsSync(dir)) {
    dir = path.join(process.cwd(), '/data.json');
  }
  if (!fs.existsSync(dir)) {
    console.log(("invalid data path: " + dir).red);
    return;
  }
  server = new MockServer(dir, {
    port: port
  });
  return process.on('SIGINT', function() {
    server.close();
    console.log("server stopped.".red);
    return process.exit();
  });
};

module.exports = bootstrap;
