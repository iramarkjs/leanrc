{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
BooleanTransform = LeanRC::BooleanTransform

describe 'BooleanTransform', ->
  describe '.new', ->
    it 'should create new boolean transform', ->
      expect ->
        transform = BooleanTransform.new()
      .to.not.throw Error
  describe '.deserialize', ->
    it 'should deserialize null value', ->
      expect BooleanTransform.new().deserialize null, allowNull: yes
      .to.equal null
    it 'should deserialize boolean value', ->
      expect BooleanTransform.new().deserialize yes
      .to.equal yes
    it 'should deserialize string value', ->
      expect BooleanTransform.new().deserialize 'True'
      .to.equal yes
    it 'should deserialize number value', ->
      expect BooleanTransform.new().deserialize 1
      .to.equal yes
  describe '.serialize', ->
    it 'should serialize null value', ->
      expect BooleanTransform.new().serialize null, allowNull: yes
      .to.equal null
    it 'should serialize boolean value', ->
      expect BooleanTransform.new().serialize yes
      .to.equal yes
    it 'should serialize string value', ->
      expect BooleanTransform.new().serialize 'True'
      .to.equal yes
    it 'should serialize number value', ->
      expect BooleanTransform.new().serialize 1
      .to.equal yes
