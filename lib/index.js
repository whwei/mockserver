var MockServer, args, bootstrap, colors, fs, path;

args = require('optimist').argv;

colors = require('colors');

fs = require('fs');

path = require('path');

MockServer = require('./mockserver');

bootstrap = function() {
  var dir, opt, ref, restart, server;
  opt = {};
  dir = path.join(process.cwd(), (ref = args.data || args.d) != null ? ref : '/data.js');
  if (args.port || args.p) {
    opt.port = args.port;
  }
  if (args.cors || args.c) {
    opt.cors = args.cors;
  }
  if (!fs.existsSync(dir)) {
    dir = path.join(process.cwd(), '/data.json');
  }
  if (!fs.existsSync(dir)) {
    console.log(("invalid data path: " + dir).red);
    return;
  }
  server = new MockServer(dir, opt);
  restart = function() {
    if (server) {
      console.log('mock data update: restarting server...');
      return server.close(function() {
        return server = new MockServer(dir, opt);
      });
    }
  };
  fs.watchFile(dir, restart);
  return process.on('SIGINT', function() {
    server.close();
    fs.unwatchFile(dir, restart);
    console.log("server stopped.".red);
    return process.exit();
  });
};

module.exports = bootstrap;
