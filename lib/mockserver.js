var MockServer, _, colors, cors, defaultOpt, express, fs, http, log, noop, path, proxy, url, wrapModule;

http = require('http');

_ = require('underscore');

url = require('url');

fs = require('fs');

path = require('path');

colors = require('colors');

express = require('express');

proxy = require('express-http-proxy');

cors = require('cors');

defaultOpt = {
  port: 9222,
  log: true
};

wrapModule = function(def, md) {
  return "(function(exports, require, module){" + def + "})(" + md + ".exports, require, " + md + ")";
};

log = console.log.bind(console);

noop = function() {
  return {};
};

MockServer = (function() {
  function MockServer(dataPath, option) {
    var md, mockData, socketId, strData, type, wrappedDef;
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
        }), 'md');
        eval(wrappedDef);
        mockData = md.exports;
      }
    } catch (_error) {
      console.error(("fail to load data: " + dataPath).red);
    }
    this._option = {};
    this._option = _.extend(this._option, defaultOpt, option);
    option = this._option;
    if (!this._option.log) {
      log = noop;
    }
    this._app = express();
    if (mockData.proxy) {
      this._app.use('/', proxy(mockData.proxy, {
        forwardPath: (function(_this) {
          return function(req, res) {
            return url.parse(req.url).path;
          };
        })(this),
        intercept: (function(_this) {
          return function(rsp, data, req, res, callback) {
            var headers;
            if (mockData.cors) {
              headers = req.get('Access-Control-Request-Headers');
              if (headers) {
                res.set('Access-Control-Allow-Headers', headers);
              }
              res.set('Access-Control-Allow-Methods', 'GET, POST, PUT');
              res.set('Access-Control-Allow-Origin', mockData.cors.origin || '*');
            }
            return callback(null, data);
          };
        })(this)
      }));
    } else {
      if (mockData.cors) {
        this._app.use(cors({
          origin: mockData.cors.origin || '*',
          methods: ['GET', 'POST', 'PUT'],
          allowedHeaders: mockData.cors.allowedHeaders
        }));
      }
      if (!mockData.routes) {
        throw new Error('Invalid mapping data');
      }
      mockData.routes.forEach((function(_this) {
        return function(route) {
          return _this.addRoute(route);
        };
      })(this));
    }
    this._server = this._app.listen(option.port, (function(_this) {
      return function() {
        log(("Starting up server at port: " + _this._option.port).yellow);
        return log('Hit CTRL-C to stop the server'.yellow);
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
      log('[%s] "%s %s" "%s"', (new Date).toLocaleString(), req.method.yellow, req.url.yellow, req.headers['user-agent'].cyan.underline);
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
