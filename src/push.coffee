# Description
#   A hubot script to push messages to subscribers
#
# Configuration:
#   HUBOT_PUSH_ALIASES - short code definitions; i.e. 'A=alfa,B=bravo'
#   HUBOT_PUSH_PORT - port to host on, defaults to 9001
#   HUBOT_PUSH_SSL_CERT - SSL cert file, if not set uses HTTP
#   HUBOT_PUSH_SSL_KEY - SSL key file, if not set uses HTTP
#
# Commands:
#   hubot push <payload> to /<channel> - send a payload to a channel
#   hubot push alias <payload> to <alias> - save a short alias for a payload
#   hubot push forget <alias> - forget a saved payload alias
#
# Notes:
#   This uses Faye under the hood, for how to subscribe check out their
#   docs, link below. The pushed messages will arrive as objects with
#   a single "payload" key that will contain the data from your message.
#   Faye Docs: http://faye.jcoglan.com/
#
# Author:
#   Mal Graty <mal.graty@googlemail.com>

module.exports = (robot) ->

  CACHE_KEY = 'hubot.push.aliases.'

  read = require('fs').readFileSync
  {NodeAdapter} = require 'faye'

  aliases = process.env.HUBOT_PUSH_ALIASES?.split(',') ? []
  crtfile = process.env.HUBOT_PUSH_SSL_CERT
  keyfile = process.env.HUBOT_PUSH_SSL_KEY

  server =
    if crtfile and keyfile
      require('https').createServer
        cert: read crtfile
        key: read keyfile
    else
      require('http').createServer()

  adapter = new NodeAdapter mount: '/', timeout: 45
  adapter.attach server

  server.listen process.env.HUBOT_PUSH_PORT ? 9001

  aliases.forEach (pair) ->
    [key, value] = pair.split '='
    robot.brain.set CACHE_KEY + key, value

  robot.respond /push alias (.+) to (\w+)/i, (msg) ->
    [_, payload, alias] = msg.match
    robot.brain.set CACHE_KEY + alias, payload
    msg.send "#{robot.name} learned #{alias}!"

  robot.respond /push forget (\w+)/i, (msg) ->
    [_, alias] = msg.match
    robot.brain.remove CACHE_KEY + alias
    msg.send "1, 2 and... Poof! #{robot.name} forgot #{alias}!"

  robot.respond /push (.+) to (\/[\w\/]+)/i, (msg) ->
    [_, payload, channel] = msg.match

    alias = robot.brain.get CACHE_KEY + payload
    payload = alias if alias

    adapter.getClient().publish channel, payload: payload

    payload = "'#{payload}'" if /\s/.test payload
    msg.send "Pushed #{payload} to #{channel}"
