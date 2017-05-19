{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Serializer = LeanRC::Serializer
Record = LeanRC::Record

describe 'Serializer', ->
  describe '#normalize', ->
    it "should normalize object value", ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attribute string: String
          @attribute number: Number
          @attribute boolean: Boolean
        Test::TestRecord.initialize()
        serializer = Serializer.new()
        record = serializer.normalize Test::TestRecord,
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        assert.instanceOf record, Test::TestRecord, 'Normalize is incorrect'
        assert.equal record.type, 'Test::TestRecord', '`type` is incorrect'
        assert.equal record.string, 'string', '`string` is incorrect'
        assert.equal record.number, 123, '`number` is incorrect'
        assert.equal record.boolean, yes, '`boolean` is incorrect'
      .to.not.throw Error
  describe '#serialize', ->
    it "should serialize Record.prototype value", ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attribute string: String
          @attribute number: Number
          @attribute boolean: Boolean
        Test::TestRecord.initialize()
        serializer = Serializer.new()
        data = serializer.serialize Test::TestRecord.new
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        assert.instanceOf data, Object, 'Serialize is incorrect'
        assert.equal data.type, 'Test::TestRecord', '`type` is incorrect'
        assert.equal data.string, 'string', '`string` is incorrect'
        assert.equal data.number, 123, '`number` is incorrect'
        assert.equal data.boolean, yes, '`boolean` is incorrect'
      .to.not.throw Error
