var MockServer, _, colors, corsMiddleWare, defaultOpt, express, fs, http, path, url, wrapModule;

http = require('http');

_ = require('underscore');

url = require('url');

fs = require('fs');

path = require('path');

colors = require('colors');

express = require('express');

defaultOpt = {
  port: 9222,
  cors: true,
  log: true
};

corsMiddleWare = function(req, res, next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Method', 'GET, PUT, POST, DELETE');
  res.header('Access-Control-Allow-Header', 'Content-Type');
  return next();
};

wrapModule = function(def, md) {
  return "(function(exports, require, module){" + def + "})(" + md + ".exports, require, " + md + ")";
};

MockServer = (function() {
  function MockServer(dataPath, option) {
    var md, mockData, originalLog, socketId, strData, type, wrappedDef;
    if (!dataPath) {
      throw new Error('mock data required');
    }
    mockData = {};
    try {
      type = path.extname(dataPath);
      if (type === '.json') {
        strData = fs.readFileSync(dataPath, {
          encoding: 'utf8'
        }).replace(/\n|\r/g, '');
        mockData = JSON.parse(strData);
      } else if (type === '.js') {
        md = {
          exports: {}
        };
        wrappedDef = wrapModule(fs.readFileSync(dataPath, {
          encoding: 'utf8'
        }), 'md').replace(/\n|\r/g, '');
        eval(wrappedDef);
        mockData = md.exports;
      }
    } catch (_error) {
      console.error(("fail to load data: " + dataPath).red);
    }
    this._option = {};
    this._option = _.extend(this._option, defaultOpt, option);
    option = this._option;
    originalLog = console.log;
    console.log = (function(_this) {
      return function() {
        if (_this._option.log) {
          return originalLog.apply(console, arguments);
        }
      };
    })(this);
    this._app = express();
    if (this._option.cors === true) {
      this._app.use(corsMiddleWare);
    }
    if (!mockData.routes) {
      throw new Error('Invalid mapping data');
    }
    mockData.routes.forEach((function(_this) {
      return function(route) {
        return _this.addRoute(route);
      };
    })(this));
    this._server = this._app.listen(option.port, (function(_this) {
      return function() {
        console.log(("Starting up server at port: " + _this._option.port).yellow);
        return console.log('Hit CTRL-C to stop the server'.yellow);
      };
    })(this));
    this._sockets = {};
    socketId = 0;
    this._server.on('connection', (function(_this) {
      return function(socket) {
        var id;
        id = socketId++;
        _this._sockets[id] = socket;
        return socket.on('close', function() {
          return delete _this._sockets[id];
        });
      };
    })(this));
  }

  MockServer.prototype.server = function() {
    return this._server;
  };

  MockServer.prototype.close = function(cb) {
    var socket;
    for (socket in this._sockets) {
      this._sockets[socket] && this._sockets[socket].destroy();
    }
    if (this._server) {
      return this._server.close(cb);
    }
  };

  MockServer.prototype.addRoute = function(route) {
    var apiPath, dataType, delay, method, ref, ref1, response;
    if (!route) {
      return;
    }
    method = (ref = route['method']) != null ? ref : 'get';
    apiPath = (ref1 = route['path']) != null ? ref1 : '/';
    response = route['response'];
    dataType = route['type'];
    delay = route['delay'] || 0;
    return this._app[method](apiPath, function(req, res) {
      var cb, query, respond, result;
      query = url.parse(req.url, true).query;
      cb = query['callback'] || query['cb'];
      result = response;
      if (typeof response === 'function') {
        result = response(req);
      }
      console.log('[%s] "%s %s" "%s"', (new Date).toLocaleString(), req.method.yellow, req.url.yellow, req.headers['user-agent'].cyan.underline);
      respond = function(result) {
        if (dataType === 'jsonp' && cb) {
          res.setHeader('Content-Type', 'application/javascript');
          return res.end(cb + "&&" + cb + "(" + (JSON.stringify(result)) + ")");
        } else {
          return res.json(result);
        }
      };
      if (delay && typeof delay === 'number') {
        return setTimeout(function() {
          return respond(result);
        }, delay);
      } else {
        return respond(result);
      }
    });
  };

  return MockServer;

})();

module.exports = MockServer;