test = require 'tape'

fb = require './index'

TIMEOUT = process.env.TIMEOUT || 5000
TOKEN = process.env.TOKEN

process.exit 1 unless TOKEN

test 'get /me', (t) ->
  fb.get '/me', TOKEN, null, TIMEOUT, (err, data) ->
    t.notok err, 'no error'
    t.ok data, 'response'
    t.end()

test 'batch', (t) ->
  fb.batch TOKEN, [
    {
      method: 'GET'
      relative_url: 'me'
    }
    {
      method: 'GET'
      relative_url: 'me/friends'
    }
   ], TIMEOUT, (err, r) ->
     t.notok err, 'no error'
     t.ok r
     t.end()
