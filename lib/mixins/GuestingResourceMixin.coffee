_             = require 'lodash'
statuses      = require 'statuses'

HTTP_NOT_FOUND    = statuses 'not found'


module.exports = (Module)->
  {
    Resource
  } = Module::

  Module.defineMixin Resource, (BaseClass) ->
    class GuestingResourceMixin extends BaseClass
      @inheritProtected()

      @public @async filterGuestList: Function,
        default: (args...)->
          @listQuery ?= {}
          if @listQuery.$filter?
            @listQuery.$filter = $and: [
              @listQuery.$filter
            ,
              '@doc.spaces': $all: ['_external']
            ]
          else
            @listQuery.$filter = '@doc.spaces': $all: ['_external']
          yield return args

      @public @async checkGuestDetail: Function,
        default: (args...)->
          unless (yield @collection.exists
            '@doc.id': $eq: @recordId
            '@doc.spaces': $all: ['_external']
          )
            @context.throw HTTP_NOT_FOUND
          yield return args


    GuestingResourceMixin.initializeMixin()
