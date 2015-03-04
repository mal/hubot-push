chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'push', ->

  before ->
    process.env.HUBOT_PUSH_ALIASES = 'A=alfa,B=bravo'
    @http = require 'http'
    @https = require 'https'
    @server = @http.createServer()

  beforeEach ->
    @http.createServer = sinon.stub().returns @server
    @https.createServer = sinon.stub().returns @server
    @robot =
      brain: set: sinon.spy()
      respond: sinon.spy()
    @server.listen = sinon.spy()
    require('../src/push')(@robot)

  describe 'when initialising', ->

    it 'should start a server on port 9001', ->
      expect(@server.listen).to.have.been.calledWith 9001

    it 'should have attached faye to the server', ->
      expect(@server.listeners('upgrade').length).to.equal 1

    it 'should populate brain with aliases', ->
      expect(@robot.brain.set).to.have.been.calledWith sinon.match(/\.A$/), 'alfa'
      expect(@robot.brain.set).to.have.been.calledWith sinon.match(/\.B$/), 'bravo'

  describe 'should register listeners for', ->

    it 'pushing', ->
      expect(@robot.respond).to.have.been.calledWith /push (.+) to (\/[\w\/]+)/i

    it 'aliasing', ->
      expect(@robot.respond).to.have.been.calledWith /push alias (.+) to (\w+)/i

    it 'forgetting', ->
      expect(@robot.respond).to.have.been.calledWith /push forget (\w+)/i

  describe 'when SSL is off', ->

    it 'should use a HTTP server', ->
      expect(@http.createServer).to.have.been.called
      expect(@https.createServer).to.not.have.been.called

  describe 'when SSL is on', ->

    before ->
      process.env.HUBOT_PUSH_SSL_KEY = '/dev/null'
      process.env.HUBOT_PUSH_SSL_CERT = '/dev/null'

    it 'should use a HTTPS server', ->
      expect(@https.createServer).to.have.been.calledWith sinon.match
        .has('cert', sinon.match.instanceOf(Buffer))
          .and(sinon.match.has('key', sinon.match.instanceOf(Buffer)))
      expect(@http.createServer).to.not.have.been.called
