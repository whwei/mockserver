var MockServer, colors, corsMiddleWare, defaultOpt, express, hostz, http, url, _;

http = require('http');

_ = require('underscore');

hostz = require('./hostz');

url = require('url');

colors = require('colors');

express = require('express');

defaultOpt = {
  port: 80,
  cors: true,
  log: true
};

corsMiddleWare = function(req, res, next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Method', 'GET, PUT, POST, DELETE');
  res.header('Access-Control-Allow-Header', 'Content-Type');
  return next();
};

MockServer = (function() {
  function MockServer(dataPath, option) {
    var mockData, originalLog;
    if (!dataPath) {
      throw new Error('mock data requried');
    }
    mockData = {};
    try {
      mockData = require(dataPath);
    } catch (_error) {
      console.error(("fail to load data: " + dataPath).red);
    }
    this._option = {};
    this._option.domain = mockData.domain || 'localhost';
    this._option.port = mockData.port || 80;
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
    if (!mockData.maps) {
      throw new Error('Invalid mapping data');
    }
    mockData.maps.forEach((function(_this) {
      return function(map) {
        return _this.addMap(map);
      };
    })(this));
    if (this._option.modifyHosts) {
      this.backupHosts();
      this.addHosts();
    }
    this._server = this._app.listen(option.port, (function(_this) {
      return function() {
        console.log(("Starting up server at port: " + _this._option.domain + ":" + _this._option.port).yellow);
        return console.log('Hit CTRL-C to stop the server'.yellow);
      };
    })(this));
  }

  MockServer.prototype.server = function() {
    return this._server;
  };

  MockServer.prototype.close = function(cb) {
    if (this._server) {
      this._server.close(cb);
    }
    if (this._option.modifyHosts) {
      return this.restoreHosts();
    }
  };

  MockServer.prototype.addMap = function(map) {
    var dataType, method, path, response, _ref, _ref1;
    if (!map) {
      return;
    }
    method = (_ref = map['method']) != null ? _ref : 'get';
    path = (_ref1 = map['path']) != null ? _ref1 : '/';
    response = map['response'];
    dataType = map['type'];
    return this._app[method](path, function(req, res) {
      var cb, query, result;
      query = url.parse(req.url, true).query;
      cb = query['callback'] || query['cb'];
      result = response;
      if (typeof response === 'function') {
        result = response(req);
      }
      console.log('[%s] "%s %s" "%s"', (new Date).toLocaleString(), req.method.yellow, req.url.yellow, req.headers['user-agent'].cyan.underline);
      if (dataType === 'jsonp' && cb) {
        res.setHeader('Content-Type', 'application/javascript');
        return res.end("" + cb + "&&" + cb + "(" + (JSON.stringify(result)) + ")");
      } else {
        return res.json(result);
      }
    });
  };

  MockServer.prototype.addHosts = function() {
    var e, target;
    target = this._option.domain;
    try {
      return hostz.add('127.0.0.1', target);
    } catch (_error) {
      e = _error;
      return console.log(e);
    }
  };

  MockServer.prototype.backupHosts = function() {
    return hostz.backup();
  };

  MockServer.prototype.restoreHosts = function() {
    return hostz.restore();
  };

  return MockServer;

})();

exports.MockServer = MockServer;
