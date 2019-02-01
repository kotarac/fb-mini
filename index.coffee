###
- shorthands exported below so you don't need so send the method
- data is optional
- path can start with a slash or not
- version is not handled
- callback receives err, data, paging, status if the response has data/paging
- callback receives err, response, status otherwise
- no timeout by default
###


host = 'https://graph.facebook.com'
r = require 'request'


api = (method, path, token, data, timeout, cb) ->
  if not cb
    cb = timeout
    timeout = null

  if not cb
    cb = data
    data = {}

  method = method.toUpperCase()
  path = path[1..] if path[0] is '/'

  options =
    method: method
    url: "#{host}/#{path}"
    headers: 'Accept': 'application/json'
    json: true
  options[if method is 'GET' then 'qs' else 'form'] = data
  options.qs or= {}
  options.qs.access_token = token
  options.timeout = timeout if timeout

  return r options, (err, response, body) ->
    return cb body.error if body?.error
    return cb err if err
    return cb null, body.data, body.summary, body.paging, response.statusCode if body.data and body.summary
    return cb null, body.data, body.paging, response.statusCode if body.data
    return cb null, body, response.statusCode


batch = (token, items, timeout, cb) ->
  if not cb
    cb = timeout
    timeout = null

  api 'post', '/', token, batch: JSON.stringify(items), timeout, (err, res) ->
    return cb err if err

    for item in res
      contentType = ''

      for header in item.headers
        contentType = header.value if header.name is 'Content-Type'

      if contentType.match /^(text\/javascript)|(application\/json)/
        item.body = JSON.parse item.body

    return cb null, res


getPaginated = (path, token, data, timeout, cb) ->
  res = []
  req = null

  if not cb
    cb = timeout
    timeout = null

  if timeout
    setTimeout ->
      req?.abort?()
      cb "Exceeded specified timeout of #{timeout}ms."
      path = null
    , timeout

  fetch = ->
    path = path[26..] if path[..25] is host

    req = api 'GET', path, token, data, timeout, (err, data, paging, status) ->
      return cb err if err

      res = res.concat data

      if paging.next
        path = paging.next
        return fetch()

      return cb null, res, status

  fetch()

  return


module.exports = {
  api
  get: api.bind undefined, 'GET'
  post: api.bind undefined, 'POST'
  put: api.bind undefined, 'PUT'
  del: api.bind undefined, 'DELETE'
  batch
  getPaginated
}
