{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Migration', ->
  describe '.new', ->
    it 'should create migration instance', ->
      co ->
        migration = LeanRC::Migration.new()
        assert.lengthOf migration.steps, 0
        yield return
  describe '.createCollection', ->
    it 'should add step for create collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.createCollection 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'createCollection'
        yield return
