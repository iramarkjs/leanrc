{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Request', ->
  describe '.new', ->
    it 'should create Request instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch:
            configs:
              trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.instanceOf request, Request
        assert.equal request.ctx, context
        assert.equal request.ip, '192.168.0.1'
        yield return
  describe '#req', ->
    it 'should get request native value', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch:
            configs:
              trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.equal request.req, context.req
        yield return
  describe '#switch', ->
    it 'should get switch internal value', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch:
            configs:
              trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.equal request.switch, context.switch
        yield return
  describe '#headers', ->
    it 'should get headers value', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch:
            configs:
              trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.equal request.headers, context.req.headers
        yield return
  describe '#header', ->
    it 'should get header value', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch:
            configs:
              trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.equal request.header, context.req.headers
        yield return
  describe '#originalUrl', ->
    it 'should get original URL', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          originalUrl: 'http://localhost:8888'
          switch:
            configs:
              trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.equal request.originalUrl, context.originalUrl
        yield return
  describe '#url', ->
    it 'should set and get native request URL', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch:
            configs:
              trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new context
        assert.equal request.url, 'http://localhost:8888'
        request.url = 'http://localhost:9999'
        assert.equal request.url, 'http://localhost:9999'
        assert.equal context.req.url, 'http://localhost:9999'
        yield return
  describe '#socket', ->
    it 'should get request socket', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch:
            configs:
              trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
            socket: {}
        request = Request.new context
        assert.equal request.socket, context.req.socket
        yield return
  describe '#protocol', ->
    it 'should get request protocol name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        request = Request.new
          switch: configs: trustProxy: no
          req:
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
        assert.equal request.protocol, 'http'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
        assert.equal request.protocol, 'http'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
            socket: encrypted: yes
        assert.equal request.protocol, 'https'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers: 'x-forwarded-for': '192.168.0.1'
            secure: yes
        assert.equal request.protocol, 'https'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers:
              'x-forwarded-for': '192.168.0.1'
              'x-forwarded-proto': 'https'
        assert.equal request.protocol, 'https'
        yield return
  describe '#get', ->
    it 'should get single header', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        context =
          switch: configs: trustProxy: yes
          req:
            url: 'http://localhost:8888'
            headers:
              'referrer': 'localhost'
              'x-forwarded-for': '192.168.0.1'
              'x-forwarded-proto': 'https'
              'abc': 'def'
        request = Request.new context
        assert.equal request.get('Referrer'), 'localhost'
        assert.equal request.get('X-Forwarded-For'), '192.168.0.1'
        assert.equal request.get('X-Forwarded-Proto'), 'https'
        assert.equal request.get('Abc'), 'def'
        assert.equal request.get('123'), ''
        yield return
  describe '#host', ->
    it 'should get full host name with port', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            headers:
              'x-forwarded-for': '192.168.0.1'
              'host': 'localhost:9999'
        assert.equal request.host, 'localhost:9999'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            headers:
              'x-forwarded-for': '192.168.0.1'
              'x-forwarded-host': 'localhost:8888, localhost:9999'
        assert.equal request.host, 'localhost:8888'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        assert.equal request.host, ''
        yield return
  describe '#origin', ->
    it 'should get request origin', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            headers:
              'x-forwarded-for': '192.168.0.1'
              'x-forwarded-proto': 'https'
              'x-forwarded-host': 'localhost:9999'
        assert.equal request.origin, 'https://localhost:9999'
        yield return
  describe '#href', ->
    it 'should get request hyper reference', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        request = Request.new
          originalUrl: 'http://localhost:8888/test'
          switch: configs: trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        assert.equal request.href, 'http://localhost:8888/test'
        request = Request.new
          originalUrl: '/test'
          switch: configs: trustProxy: yes
          req:
            headers:
              'x-forwarded-for': '192.168.0.1'
              'x-forwarded-proto': 'https'
              'x-forwarded-host': 'localhost:9999'
        assert.equal request.href, 'https://localhost:9999/test'
        yield return
  describe '#method', ->
    it 'should get and set request method', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        req =
          method: 'POST'
          headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new
          originalUrl: '/test'
          switch: configs: trustProxy: yes
          req: req
        assert.equal request.method, 'POST'
        request.method = 'PUT'
        assert.equal request.method, 'PUT'
        assert.equal req.method, 'PUT'
        yield return
  describe '#path', ->
    it 'should get and set request path', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        req =
          url: 'https://localhost:8888/test?t=ttt'
          method: 'POST'
          headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new
          switch: configs: trustProxy: yes
          req: req
        assert.equal request.path, '/test'
        request.path = '/test1'
        assert.equal request.path, '/test1'
        assert.equal req.url, 'https://localhost:8888/test1?t=ttt'
        yield return
  describe '#querystring', ->
    it 'should get and set query string', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        req =
          url: 'https://localhost:8888/test?t=ttt'
          method: 'POST'
          headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new
          switch: configs: trustProxy: yes
          req: req
        assert.equal request.querystring, 't=ttt'
        request.querystring = 'a=aaa'
        assert.equal request.querystring, 'a=aaa'
        assert.equal req.url, 'https://localhost:8888/test?a=aaa'
        yield return
  describe '#search', ->
    it 'should get and set search string', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        req =
          url: 'https://localhost:8888/test?t=ttt'
          method: 'POST'
          headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new
          switch: configs: trustProxy: yes
          req: req
        assert.equal request.search, '?t=ttt'
        request.search = 'a=aaa'
        assert.equal request.search, '?a=aaa'
        assert.equal req.url, 'https://localhost:8888/test?a=aaa'
        yield return
  describe '#query', ->
    it 'should get and set query params', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        req =
          url: 'https://localhost:8888/test?t=ttt'
          method: 'POST'
          headers: 'x-forwarded-for': '192.168.0.1'
        request = Request.new
          switch: configs: trustProxy: yes
          req: req
        assert.deepEqual request.query, t: 'ttt'
        request.query = a: 'aaa'
        assert.deepEqual request.query, a: 'aaa'
        assert.equal req.url, 'https://localhost:8888/test?a=aaa'
        yield return
  describe '#hostname', ->
    it 'should get host name without port', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            headers:
              'x-forwarded-for': '192.168.0.1'
              'host': 'localhost:9999'
        assert.equal request.hostname, 'localhost'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            headers:
              'x-forwarded-for': '192.168.0.1'
              'x-forwarded-host': 'localhost1:8888, localhost2:9999'
        assert.equal request.hostname, 'localhost1'
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            headers: 'x-forwarded-for': '192.168.0.1'
        assert.equal request.hostname, ''
        yield return
  describe '#fresh', ->
    it 'should test request freshness', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        request = Request.new
          status: 200
          switch: configs: trustProxy: yes
          response:
            headers: 'etag': '"bar"'
          req:
            method: 'GET'
            headers:
              'x-forwarded-for': '192.168.0.1'
              'if-none-match': '"foo"'
        assert.isFalse request.fresh
        request = Request.new
          status: 200
          switch: configs: trustProxy: yes
          response:
            headers: 'etag': '"foo"'
          req:
            method: 'GET'
            headers:
              'x-forwarded-for': '192.168.0.1'
              'if-none-match': '"foo"'
        assert.isTrue request.fresh
        yield return
  describe '#stale', ->
    it 'should test inverted request freshness', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        request = Request.new
          status: 200
          switch: configs: trustProxy: yes
          response:
            headers: 'etag': '"bar"'
          req:
            method: 'GET'
            headers:
              'x-forwarded-for': '192.168.0.1'
              'if-none-match': '"foo"'
        assert.isTrue request.stale
        request = Request.new
          status: 200
          switch: configs: trustProxy: yes
          response:
            headers: 'etag': '"foo"'
          req:
            method: 'GET'
            headers:
              'x-forwarded-for': '192.168.0.1'
              'if-none-match': '"foo"'
        assert.isFalse request.stale
        yield return
  describe '#idempotent', ->
    it 'should test if method is idempotent', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Request extends LeanRC::Request
          @inheritProtected()
          @module Test
        Request.initialize()
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            method: 'GET'
            headers:
              'x-forwarded-for': '192.168.0.1'
        assert.isTrue request.idempotent
        request = Request.new
          switch: configs: trustProxy: yes
          req:
            method: 'POST'
            headers:
              'x-forwarded-for': '192.168.0.1'
        assert.isFalse request.idempotent
        yield return
