_ = require 'lodash'
RC = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::DateTransform extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::TransformInterface

    @Module: LeanRC

    @public deserialize: Function,
      default: (serialized)->
        if _.isNil(serialized) then null else new Date serialized

    @public serialize: Function,
      default: (deserialized)->
        if _.isDate(deserialized) and not _.isNaN(deserialized)
          return deserialized.toISOString()
        else
          return null


  return LeanRC::DateTransform.initialize()
