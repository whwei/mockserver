var url = require('url');

var mockData = {
    name: 'fixture',
    domain: 'api.interfacedomain.com',
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
                        name: 'people ' + count
                    };
                }
            })()
        },
        {
            path: '/people_jsonp',
            method: 'get',
            type: 'jsonp',
            response: (function() {
                var count = 1;

                return function() {
                    count++;
                    return {
                        id: count,
                        name: 'people ' + count
                    };
                }
            })()
        },
        {
            path: '/player',
            method: 'get',
            response: function(req) {
                var query = url.parse(req.url).query;

                switch(query.team) {
                    case 'rockets':
                        return [
                            {
                                number: 11,
                                name: 'Yao Ming'
                            },
                            {
                                number: 1,
                                name: 'Tracy McGrady'
                            }
                        ];
                        break;
                    case 'lakers':
                        return [
                            {
                                number: 24,
                                name: 'Kobe Bryant'
                            },
                            {
                                number: 0,
                                name: 'Nick Young'
                            },
                            {
                                number: 17,
                                name: 'Jeremy Lin'
                            }
                        ];
                        break;
                    default:
                        return [];
                        break;
                }


            }
        }
    ]
};

module.exports = mockData;
