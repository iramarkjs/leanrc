
RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ArangoCursorInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public setCursor: Function,
      args: [RC::Constants.ANY]
      return: ArangoCursorInterface

    @public setRecord: Function,
      args: [RC::Class]
      return: ArangoCursorInterface

    @public toArray: Function,
      args: [[RC::Class. RC::Constants.NILL]]
      return: Array

    @public next: Function,
      args: [[RC::Class. RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public hasNext: Function,
      args: []
      return: Boolean

    @public getExtra: Function,
      args: []
      return: RC::Constants.ANY

    @public setBatchSize: Function,
      args: [Number]
      return: RC::Constants.NILL

    @public getBatchSize: Function,
      args: []
      return: RC::Constants.ANY

    @public dispose: Function,
      args: []
      return: RC::Constants.NILL

    @public count: Function,
      args: []
      return: Number

    @public forEach: Function,
      args: [Function, [RC::Class. RC::Constants.NILL]]
      return: RC::Constants.NILL

    @public map: Function,
      args: [Function, [RC::Class. RC::Constants.NILL]]
      return: Array

    @public filter: Function,
      args: [Function, [RC::Class. RC::Constants.NILL]]
      return: Array

    @public find: Function,
      args: [Function, [RC::Class. RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public compact: Function,
      args: [[RC::Class. RC::Constants.NILL]]
      return: Array

    @public reduce: Function,
      args: [Function, RC::Constants.ANY, [RC::Class. RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public first: Function,
      args: [[RC::Class. RC::Constants.NILL]]
      return: RC::Constants.ANY


  return LeanRC::ArangoCursorInterface.initialize()
