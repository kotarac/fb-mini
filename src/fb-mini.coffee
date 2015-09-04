###
- shorthands exported below so you don't need so send the method
- data is optional
- path can start with a slash or not
- version is not handled
- callback receives err, data, paging, status if the response has data/paging
- callback receives err, response, status otherwise
###


debug = require('debug')('fb')
host = 'https://graph.facebook.com'
r = require 'superagent'


api = (method, path, token, data, cb) ->
    method = method.toLowerCase()

    if not cb?
        cb = data
        data = {}

    path = path[1..] if path[0] is '/'
    dataMethod = if method is 'get' then 'query' else 'send'

    debug "#{method.toUpperCase()} #{path} #{token}"
    debug data

    request = r[method] "#{host}/#{path}"
        .query access_token: token
        .set 'Accept', 'application/json'
    request[dataMethod] data
        .end (err, res) ->
            return cb res.body.error if res?.body?.error?
            return cb err if err
            return cb null, res.body.data, res.body.paging, res.statusCode if res.body.data?
            return cb null, res.body, res.statusCode


batch = (token, items, cb) ->
    debug 'BATCH'
    debug items

    api 'post', '/v2.4', token, batch: items, (err, res) ->
        return cb err if err

        for item in res
            contentType = ''

            for header in item.headers
                contentType = header.value if header.name is 'Content-Type'

            if contentType.match /^(text\/javascript)|(application\/json)/
                item.body = JSON.parse item.body

        return cb null, res


module.exports =
    api: api
    get: api.bind undefined, 'get'
    post: api.bind undefined, 'post'
    put: api.bind undefined, 'put'
    del: api.bind undefined, 'del'
    batch: batch
