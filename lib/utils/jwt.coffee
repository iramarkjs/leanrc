

# Algorithms supported
# HS256 |-> HMAC using SHA-256 hash algorithm
# HS384 |-> HMAC using SHA-384 hash algorithm
# HS512 |-> HMAC using SHA-512 hash algorithm
# RS256 |-> RSASSA using SHA-256 hash algorithm
# RS384 |-> RSASSA using SHA-384 hash algorithm
# RS512 |-> RSASSA using SHA-512 hash algorithm
# ES256 |-> ECDSA using P-256 curve and SHA-256 hash algorithm
# ES384 |-> ECDSA using P-384 curve and SHA-384 hash algorithm
# ES512 |-> ECDSA using P-521 curve and SHA-512 hash algorithm


module.exports = (Module) ->
  isArango = Module::Utils.isArangoDB()
  Module::Utils.jwtDecode = (asKey, asToken, abNoVerify = no) ->
    Module::Promise.new (resolve, reject) ->
      if isArango or not Module::Utils.hasNativePromise()
        # Is ArangoDB !!!
        try
          crypto = require '@arangodb/crypto'
          decoded = crypto.jwtDecode asKey, asToken, abNoVerify
        catch e
          return reject e
        resolve decoded
      else
        # Is Node.js !!!
        try
          jwt = require 'jsonwebtoken'
          decoded = if abNoVerify
            jwt.decode asToken
          else
            jwt.verify asToken, asKey
        catch e
          return reject e
        resolve decoded
      return

  Module::Utils.jwtEncode = (asKey, asMessage, asAlgorithm) ->
    Module::Promise.new (resolve, reject) ->
      if isArango or not Module::Utils.hasNativePromise()
        # Is ArangoDB !!!
        try
          crypto = require '@arangodb/crypto'
          encoded = crypto.jwtEncode asKey, asMessage, asAlgorithm
        catch e
          return reject e
        resolve encoded
      else
        # Is Node.js !!!
        try
          jwt = require 'jsonwebtoken'
          encoded = jwt.sign asMessage, asKey, algorithm: asAlgorithm
        catch e
          return reject e
        resolve encoded
      return