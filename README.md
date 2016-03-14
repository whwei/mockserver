# Mockserver
set up your api server using local config file.

[![Build Status](https://travis-ci.org/whwei/mockserver.svg?branch=master)](https://travis-ci.org/whwei/mockserver)

## Install
```
git clone https://github.com/whwei/mockserver.git
cd mockserver
npm link
```

## Usage
to start a server:
```
mockserver -d path-to-config-file.json
```

or, you already have a config file named `data.js` or `data.json` in current directory, just type:
```
mockserver
```

## Options
-   `-d`: config file path
-   `-p`: port

## Config file

### JS
```javascript
// data.js

var data = {
    name: 'api',

    // support cors
    cors: {
        allowedHeaders: 'X-Header, X-Header-2'
    },

    // response status code
    status: 200,

    // as proxy
    proxy: 'http://www.proxy.com',

    routes: [
        {
            path: '/people',
            method: 'get',
            response: (function() {
                var count = 1;

                return function() {
                    count++;
                    return {
                        id: count,
                        name: 'people' + count
                    };
                }
            })()
        }
    ]
};

module.exports = data;
```

you can respond different data according to the `request`.
```javascript
var data = {
    name: 'api',
    routes: [
        {
            path: '/people',
            method: 'get',
            response: function(req) {
                var query = url.parse(req.url).query || {};

                // ......
            }
        }
    ]
};

module.exports = data;
```


### JSON
```json
{
    "name": "fixture",
    "cors": {
        "allowedHeaders": "X-Header, X-Header-2"
    },
    "status": 200,
    "routes": [
        {
            "path": "/people",
            "method": "get",
            "response": [
                {
                    "id": "000001",
                    "name": "Alice"
                },
                {
                    "id": "000002",
                    "name": "Bob"
                }
            ]
        }
    ]
}
```
