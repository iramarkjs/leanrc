
# миксин подмешивается к классам унаследованным от Module::Resource
# если необходимо переопределить экшен list так чтобы он принимал квери (из браузера) и отдавал не все рекорды в коллекции, а только отфильтрованные
# а также для добавления экшена query который будет использоваться из HttpCollectionMixin'а


module.exports = (Module)->
  {
    Resource
    Utils: { _, isArangoDB, joi }
  } = Module::

  Module.defineMixin 'QueryableResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      MAX_LIMIT   = 50

      @public @async writeTransaction: Function,
        args: [String, Module::ContextInterface]
        return: Boolean
        default: (asAction, aoContext) ->
          result = yield @super asAction, aoContext
          if result
            if asAction is 'query'
              body = if isArangoDB()
                aoContext.req.body
              else
                parse = require 'co-body'
                yield parse aoContext.req
              { query } = body ? {}
              if query?
                key = _.findKey query, (v, k) -> k in [
                  '$patch', '$remove'
                ]
                result = key?
          yield return result

      @action @async list: Function,
        default: ->
          receivedQuery = _.pick @listQuery, [
            '$filter', '$sort', '$limit', '$offset'
          ]
          voQuery = Module::Query.new()
            .forIn '@doc': @collection.collectionFullName()
            .return '@doc'
          if receivedQuery.$filter
            do =>
              { error } = joi.validate receivedQuery.$filter, joi.object()
              if error?
                @context.throw 400, 'ValidationError: `$filter` must be an object', error.stack
            voQuery.filter receivedQuery.$filter
          if receivedQuery.$sort
            do =>
              { error } = joi.validate receivedQuery.$sort, joi.array().items joi.object()
              if error?
                @context.throw 400, 'ValidationError: `$sort` must be an array'
            receivedQuery.$sort.forEach (item)->
              voQuery.sort item
          if receivedQuery.$limit
            do =>
              { error } = joi.validate receivedQuery.$limit, joi.number()
              if error?
                @context.throw 400, 'ValidationError: `$limit` must be a number', error.stack
            voQuery.limit receivedQuery.$limit
          if receivedQuery.$offset
            do =>
              { error } = joi.validate receivedQuery.$offset, joi.number()
              if error?
                @context.throw 400, 'ValidationError: `$offset` must be a number', error.stack
            voQuery.offset receivedQuery.$offset

          limit = Number voQuery.$limit
          if @needsLimitation
            voQuery.limit switch
              when limit > MAX_LIMIT, limit < 0, isNaN limit then MAX_LIMIT
              else limit
          else unless isNaN limit
            voQuery.limit limit
          skip = Number voQuery.$offset
          voQuery.offset switch
            when skip < 0, isNaN skip then 0
            else skip

          vlItems = yield (yield @collection.query voQuery).toArray()
          return {
            meta:
              pagination:
                limit: voQuery.$limit
                offset: voQuery.$offset
            items: vlItems
          }

      @action @async query: Function,
        default: ->
          {body} = @context.request
          return yield (yield @collection.query body.query).toArray()

      # ------------ Chains definitions ---------
      @chains ['query', 'list']
      # @initialHook 'requiredAuthorizationHeader', only: ['query']
      @initialHook 'parseBody', only: ['query']


      @initializeMixin()
