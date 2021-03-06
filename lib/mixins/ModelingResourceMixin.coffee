# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

module.exports = (Module)->
  {
    SESSIONS
    USERS
    PromiseT
    FuncG
    RecordInterface
    Resource, Mixin
    Utils: { _, statuses, co }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  UNAUTHORIZED      = statuses 'unauthorized'

  Module.defineMixin Mixin 'ModelingResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @public namespace: String,
        default: 'modeling'

      @public currentSpaceId: String,
        default: '_internal'

      @public needsLimitation: Boolean,
        default: no

      @public session: RecordInterface
      @public currentUser: PromiseT,
        get: co.wrap ->
          return yield @facade.retrieveProxy(USERS).find 'system'

      @beforeHook 'setSpaces',      only: ['create']
      @beforeHook 'setOwnerId',     only: ['create']
      @beforeHook 'protectSpaces',  only: ['update']
      @beforeHook 'protectOwnerId', only: ['update']

      @public checkHeader: FuncG([], Boolean),
        default: ->
          { apiKey } = @configs
          {
            authorization: authHeader
          } = @context.headers
          return no   unless authHeader?
          [..., key] = (/^Bearer\s+(.+)$/.exec authHeader) ? []
          return no   unless key?
          return apiKey is key

      @public @async makeSession: Function,
        default: ->
          SessionsCollection = @facade.retrieveProxy SESSIONS
          if @checkHeader()
            session = yield SessionsCollection.build {uid: 'system'}
          unless session?
            session = yield SessionsCollection.build({})
          @session = session
          yield return

      @public @async systemOnly: Function,
        default: (args...)->
          yield @makeSession()
          unless @session.uid?
            @context.throw UNAUTHORIZED
            return
          # UsersCollection = @facade.retrieveProxy USERS
          # currentUser = yield UsersCollection.build
          #   id: 'system'
          #   handle: 'system'
          #   email: 'system@leanrc.com'
          #   firstName: 'Owner'
          #   lastName: 'System'
          #   role: 'admin'
          #   accepted:                       yes
          #   verified:                       yes
          #   ownerId: 'system'
          #   inviterId: 'admin'
          # @currentUser = currentUser
          yield return args

      @public @async setOwnerId: Function,
        default: (args...)->
          @recordBody.ownerId = 'system'
          yield return args

      @public @async setSpaces: Function,
        default: (args...)->
          @recordBody.spaces ?= []
          unless _.includes @recordBody.spaces, @currentSpaceId
            @recordBody.spaces.push @currentSpaceId
          yield return args

      @public @async protectSpaces: Function,
        default: (args...)->
          @recordBody = _.omit @recordBody, ['spaces']
          yield return args

      @public getRecordId: Function,
        default: (args...)->
          @super args...
          @recordId ?= @context.pathParams["modeling_#{@keyName}"]
          return args


      @initializeMixin()
