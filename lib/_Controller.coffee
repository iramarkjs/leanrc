_           = require 'lodash'
joi         = require 'joi'
inflect     = require('i')()
crypto      = require '@arangodb/crypto'


status      = require 'statuses'
{ errors }  = require '@arangodb'

MAX_LIMIT   = 50

ARANGO_NOT_FOUND  = errors.ERROR_ARANGO_DOCUMENT_NOT_FOUND.code
ARANGO_DUPLICATE  = errors.ERROR_ARANGO_UNIQUE_CONSTRAINT_VIOLATED.code
ARANGO_CONFLICT   = errors.ERROR_ARANGO_CONFLICT.code
HTTP_NOT_FOUND    = status 'not found'
HTTP_CONFLICT     = status 'conflict'
UNAUTHORIZED      = status 'unauthorized'
FORBIDDEN         = status 'forbidden'
UPGRADE_REQUIRED  = status 'upgrade required'

###
  ````
    Controller = require '../lib/controller'
    class TomatosController extends Controller
      Model: Tomato
      constructor: ->
        super arguments...

      updateMethods: -> ["#{@Model.name}.update"] # если внутри функции update вызывается метод класса то в формате '<имя класса в камелкейсе>.<имя метода класса>'
      updateCollections: -> {}
      update: ->
        tomato = @Model.update arguments...
        console.log 'kkk', tomato
        tomato

    class CucumbersController extends Controller
      Model: Cucumber
      constructor: ->
        super arguments...
        @tomato = new TomatosController()

      updateMethods: -> ['TomatosController::update'] # если внутри функции update вызывается метод экземпляра класса то в формате '<имя класса в камелкейсе>::<имя метода экземпляра класса>'
      updateCollections: ->
        {}
      update: ->
        @tomato.update()
        console.log 'jjj'

    tomato = new TomatosController()
    cucumber = new CucumbersController()

    CucumbersController.getLocksFor 'CucumbersController::update'
  ```
  # детальнее про объявление используемых в методе вызовах можно посмотреть в базовом классе Model

  # детальнее про объявление цепей можно посмотреть в базовом классе Model

  # @StateMachine объявлять в контроллерах очень не рекомендуется, хоть эта техника и объявлена в CoreObject, но на данный момент должна использоваться только в моделях, т.к. только объекты моделей релаьно могут быть сохранены в базе данных
  # контроллеры существуют временно как объекты в оперативной памяти пока ндо обработать пришедший на сервер request и отправить response
  # сервер состояние не хранит. поэтому объявление машин состояний в контроллерах - бессмысленно.

  # Возможно за очень редким исключением в контроллере может быть не нужно объявлять модель через
  ```
    Controller = require '../lib/controller'
    Tomato = require = '../models/tomato'
    TomatosController extends Controller
      Model: Tomato

    module.exports = TomatosController
  ```
  Это обязательно надо делать, если контроллер должен получать из браузера объекты какогото типа и сохранять в какуюто определенную коллекцию
  или если должен отдавать в браузер из коллекции в базе с помощью какой-то модели эти данные в браузер.

  Если в роутере объявлен дополнительный экшен (метод) для какого-то контроллера
  помимо того, что в контроллере должен быть объявлен метод с тем же именем,
  для этого метода должны быть определены дифиниции для вычисления read-write локов для транзакций,
  и так же надо объявить описание swaggerDefinition, например
  ```
    @swaggerDefinition 'update', (endpoint)->
      @isValid()
      endpoint.pathParam 'key', @keySchema
        .body         @clientSchema().required(), "The data to replace the #{inflect.singularize inflect.underscore @::Model.name} with."
        .response     @clientSchema(), "The new #{inflect.singularize inflect.underscore @::Model.name}."
        .error        HTTP_NOT_FOUND
        .error        HTTP_CONFLICT
        .error        UNAUTHORIZED
        .summary      "Replace a #{inflect.singularize inflect.underscore @::Model.name}"
        .description  "
          Replaces an existing #{inflect.singularize inflect.underscore @::Model.name} with the request body and
          returns the new document.
        "
  ```

  # Со всеми остальными методами класса и методами экземпляра класса Controller лучше ознакомитсья самостоятельно ниже по коду
  # их логика работы довольно проста для понимания
###
module.exports = (FoxxMC)->
  CoreObject  = require('./CoreObject') FoxxMC
  extend      = require('./utils/extend') FoxxMC

  class FoxxMC::Controller extends CoreObject
    Model: null
    query: null
    body: null
    recordId: null
    patchData: null
    currentUser: null

    @swaggerDefinition: (action, lambda)->
      @["_swaggerDefFor_#{action}"] = lambda

    @keyName: ->
      inflect.singularize inflect.underscore @name.replace 'Controller', ''

    @swaggerDefinition 'list', (endpoint)->
      @isValid()
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .queryParam   'query', @querySchema, "
          The query for finding
          #{inflect.pluralize inflect.underscore @::Model.name}.
        "
        .response     @clientSchemaForArray(), "
          The #{inflect.pluralize inflect.underscore @::Model.name}.
        "
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .summary      "
          List of filtered #{inflect.pluralize inflect.underscore @::Model.name}
        "
        .description  "
          Retrieves a list of filtered
          #{inflect.pluralize inflect.underscore @::Model.name} by using query.
        "

    @swaggerDefinition 'detail', (endpoint)->
      @isValid()
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .pathParam    @keyName(), @keySchema
        .response     @clientSchema(), "
          The #{inflect.singularize inflect.underscore @::Model.name}.
        "
        .error        HTTP_NOT_FOUND
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .summary      "
          Fetch the #{inflect.singularize inflect.underscore @::Model.name}
        "
        .description  "
          Retrieves the
          #{inflect.singularize inflect.underscore @::Model.name} by its key.
        "

    @swaggerDefinition 'create', (endpoint)->
      @isValid()
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .body @clientSchema().required(), "
          The #{inflect.singularize inflect.underscore @::Model.name} to create.
        "
        .response     201, @clientSchema(), "
          The created #{inflect.singularize inflect.underscore @::Model.name}.
        "
        .error        HTTP_CONFLICT, "
          The #{inflect.singularize inflect.underscore @::Model.name} already
          exists.
        "
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .summary      "
          Create a new #{inflect.singularize inflect.underscore @::Model.name}
        "
        .description  "
          Creates a new #{inflect.singularize inflect.underscore @::Model.name}
          from the request body and
          returns the saved document.
        "

    @swaggerDefinition 'update', (endpoint)->
      @isValid()
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .pathParam @keyName(), @keySchema
        .body         @clientSchema().required(), "
          The data to replace the
          #{inflect.singularize inflect.underscore @::Model.name} with.
        "
        .response     @clientSchema(), "
          The new #{inflect.singularize inflect.underscore @::Model.name}.
        "
        .error        HTTP_NOT_FOUND
        .error        HTTP_CONFLICT
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .summary      "
          Replace the #{inflect.singularize inflect.underscore @::Model.name}
        "
        .description  "
          Replaces an existing
          #{inflect.singularize inflect.underscore @::Model.name} with the
          request body and returns the new document.
        "

    @swaggerDefinition 'patch', (endpoint)->
      @isValid()
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .pathParam @keyName(), @keySchema
        .body         @clientSchema().description("
          The data to update the
          #{inflect.singularize inflect.underscore @::Model.name} with.
        ").required()
        .response     @clientSchema(), "
          The updated #{inflect.singularize inflect.underscore @::Model.name}.
        "
        .error        HTTP_NOT_FOUND
        .error        HTTP_CONFLICT
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .summary      "
          Update the #{inflect.singularize inflect.underscore @::Model.name}
        "
        .description  "
          Patches the #{inflect.singularize inflect.underscore @::Model.name}
          with the request body and returns the updated document.
        "

    @swaggerDefinition 'delete', (endpoint)->
      @isValid()
      endpoint
        .pathParam   'v', joi.string().required(), "
          The version of api endpoint in format `vx.x`
        "
        .pathParam @keyName(), @keySchema
        .error        HTTP_NOT_FOUND
        .error        UNAUTHORIZED
        .error        UPGRADE_REQUIRED
        .response     null
        .summary      "
          Remove the #{inflect.singularize inflect.underscore @::Model.name}
        "
        .description  "
          Deletes the #{inflect.singularize inflect.underscore @::Model.name}
          from the database.
        "
    @keySchema:     joi.string().required().description 'The key of the objects.'
    @querySchema:   joi.string().empty('{}').optional().default '{}', '
      The query for finding objects.
    '

    @schema: ->
      @isValid()
      joi.object @::Model.serializableAttributes()

    @clientSchema: ->
      @isValid()
      joi.object "#{inflect.underscore @::Model.name}": @schema()

    @clientSchemaForArray: ->
      @isValid()
      joi.object "#{inflect.pluralize inflect.underscore @::Model.name}": joi.array().items @schema()

    @itemForClient: (item, opts = {})->
      @isValid()
      key = opts.singularize ? inflect.singularize inflect.underscore @::Model.name
      data = item.serializeForClient opts
      return "#{key}": data

    @itemsForClient: (items, meta, opts = {})->
      @isValid()
      key = opts.pluralize ? inflect.pluralize inflect.underscore @::Model.name
      results = []
      items.forEach (item) ->
        results.push item.serializeForClient opts
      return "#{key}": results, meta: meta

    # ------------ Default definitions ---------
    @chains ['list', 'detail', 'create', 'update', 'delete']

    @initialHook 'initializeDependencies'
    @initialHook 'checkApiVersion'

    @beforeHook 'beforeList',       only: ['list']
    @beforeHook 'beforeDetail',     only: ['detail']
    @beforeHook 'beforeCreate',     only: ['create']
    @beforeHook 'beforeUpdate',     only: ['update']
    @beforeHook 'beforeDelete',     only: ['delete']

    @beforeHook 'permitBody',       only: ['create', 'update']
    @beforeHook 'setOwnerId',       only: ['create']
    @beforeHook 'protectOwnerId',   only: ['update']
    @beforeHook 'protectSpaceId',   only: ['update']

    @afterHook 'afterCreate',       only: ['create']
    @afterHook 'afterUpdate',       only: ['update']
    @afterHook 'afterDelete',       only: ['delete']

    @finallyHook 'itemDecorator',   only: ['detail', 'create', 'update']
    @finallyHook 'deleteDecorator', only: ['delete']
    @finallyHook 'listDecorator',   only: ['list']

    @actions: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @actions AbstractClass.__super__.constructor
      _.uniq [].concat(fromSuper ? [])
        .concat(AbstractClass["_#{AbstractClass.name}_actions"] ? [])

    @action: (name)->
      @["_#{@name}_actions"] ?= []
      @["_#{@name}_actions"].push name
      @instanceMethod arguments...

    # ------------- Instanse methods ----------
    itemDecorator: (item)->
      @constructor.itemForClient item

    itemsDecorator: (items)->
      @constructor.itemsForClient items

    deleteDecorator: (items)->
      null

    listDecorator: ({data, meta})->
      result = @constructor.itemsForClient data, meta
      result

    @isValid: ->
      @::isValid()

    isValid: ->
      unless @Model?
        # console.log '%#$%#%@#$@#$@#$@#$@#$@#$@#$'
        throw new Error "@Model is required properties for #{@constructor.name}"
        return
      else
        return

    constructor: (opts={}) ->
      {@req, @res} = opts
      # console.log 'Init of Controller'
      super arguments...
      return

    initializeDependencies: (args...)->
      console.log '???? test @Module', @Module
      @constructor.Module.initializeModules()
      args

    checkApiVersion: (args...)->
      vVersion = @req.pathParams.v
      vCurrentVersion = @constructor.Module.context.manifest.version
      [vNeedVersion] = vCurrentVersion.match /^\d{1,}[.]\d{1,}/
      sendError = =>
        @res.throw UPGRADE_REQUIRED, "Upgrade: v#{vNeedVersion}"
      unless /^[v]\d{1,}[.]\d{1,}/.test vVersion
        sendError()
      unless new RegExp(vVersion).test "v#{vCurrentVersion}"
        sendError()
      args

    permitBody: ->
      @isValid()
      {value:data} = @constructor.clientSchema().validate @body
      @patchData = data["#{inflect.underscore @Model.name}"]
      return

    setOwnerId: ->
      @isValid()
      @body.ownerId = @currentUser?._key ? null
      return

    protectOwnerId: ->
      @isValid()
      @body = _.omit @body, ['ownerId']
      return

    protectSpaceId: ->
      @isValid()
      @body = _.omit @body, ['spaceId']
      return

    beforeList: ->
      { currentUser } = @req
      query = JSON.parse @req.queryParams['query']
      limit = Number query.limit
      query.limit = switch
        when limit > MAX_LIMIT, limit < 0, isNaN limit then MAX_LIMIT
        else limit
      page = Number query.page
      unless isNaN page
        query.offset = (page - 1) * query.limit
      skip = Number query.offset
      query.offset = switch
        when skip < 0, isNaN skip then 0
        else skip
      {@query, @currentUser} = {query, currentUser}
      return

    beforeLimitedList: (query = {}) ->
      { currentUser } = @req
      if currentUser? and not currentUser.isAdmin
        query.ownerId = currentUser._key
      {@query, @currentUser} = {query, currentUser}
      return

    beforeDetail: ->
      { currentUser } = @req
      recordId = @req.pathParams[@constructor.keyName()]
      {@recordId, @currentUser} = {recordId, currentUser}
      return

    beforeCreate: ->
      {@body, @currentUser} = @req
      return

    beforeUpdate: ->
      { currentUser } = @req
      recordId = @req.pathParams[@constructor.keyName()]
      body = extend {}, @req.body,
        "#{inflect.underscore @Model.name}":
          id: recordId
      {@recordId, @body, @currentUser} = {recordId, body, currentUser}
      return

    beforeDelete: ->
      { currentUser } = @req
      recordId = @req.pathParams[@constructor.keyName()]
      {@recordId, @currentUser} = {recordId, currentUser}
      return

    afterCreate: (data)->
      data

    afterUpdate: (data)->
      data

    afterDelete: (data)->
      data

    _checkHeader: (req) ->
      { apiKey }        = @Module.context.configuration
      {
        authorization: authHeader
      } = req.headers
      return no   unless authHeader?
      [..., key] = (/^Bearer\s+(.+)$/.exec authHeader) ? []
      return no   unless key?
      encryptedApiKey = crypto.sha512 apiKey
      crypto.constantEquals encryptedApiKey, key

    checkSession: (args...)->
      # Must be implemented CheckSessionMixin and inclede in all controllers
      @req.currentUser = {}
      args

    checkOwner: @method [], ->
      @isValid()
      read: [ @Model.collectionName() ]
    , (args...) ->
      @isValid()
      unless @req.session?.uid? and @req.currentUser?
        @res.throw UNAUTHORIZED
        return
      if @req.currentUser.isAdmin
        return args
      unless (key = @req.pathParams[@constructor.keyName()])?
        return args
      doc = @Model.find key, @req.currentUser
      unless doc?
        @res.throw HTTP_NOT_FOUND
      unless doc._owner
        return args
      if @req.currentUser._key isnt doc._owner
        @res.throw FORBIDDEN
        return
      args

    adminOnly: (args...) ->
      unless @req.session?.uid? and @req.currentUser?
        @res.throw UNAUTHORIZED
        return
      unless @req.currentUser.isAdmin
        @res.throw FORBIDDEN
        return
      args

    @action 'list', ->
      @isValid()
      ["#{@Model.name}.query"]
    , ->
      cursor = @Model.query @query, @currentUser
        .exec()
      return {
        meta:
          pagination:
            total: cursor.total()
            limit: cursor.limit()
            offset: cursor.offset()
        data: cursor.toArray()
      }

    @action 'detail', ->
      @isValid()
      ["#{@Model.name}.find"]
    , ->
      @isValid()
      @Model.find @recordId, @currentUser

    @action 'create', ->
      @isValid()
      ["#{@Model.name}.create"]
    , ->
      @isValid()
      @Model.create @patchData, @currentUser

    @action 'update', ->
      @isValid()
      ["#{@Model.name}.update"]
    , ->
      @isValid()
      @Model.update @recordId, @patchData, @currentUser

    @action 'delete', ->
      @isValid()
      ["#{@Model.name}.delete"]
    , ->
      @isValid()
      @Model.delete @recordId, @currentUser


  FoxxMC::Controller.initialize()