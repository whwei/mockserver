var MockServer, args, bootstrap, colors, fs, path;

args = require('optimist').argv;

colors = require('colors');

fs = require('fs');

path = require('path');

MockServer = require('./mockserver').MockServer;

bootstrap = function() {
  var dir, opt, server, _ref;
  opt = {};
  dir = path.join(process.cwd(), (_ref = args.data || args.d) != null ? _ref : '/data.js');
  opt.port = args.port || args.p || 80;
  opt.modifyHosts = args.hosts || args.h;
  if (opt.modifyHosts) {
    opt.port = 80;
  }
  if (!fs.existsSync(dir)) {
    dir = path.join(process.cwd(), '/data.json');
  }
  if (!fs.existsSync(dir)) {
    console.log(("invalid data path: " + dir).red);
    return;
  }
  server = new MockServer(dir, opt);
  return process.on('SIGINT', function() {
    server.close();
    console.log("server stopped.".red);
    return process.exit();
  });
};

module.exports = bootstrap;
