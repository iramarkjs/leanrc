

module.exports = (Module)->
  {
    CrudEndpointMixin
    Utils: { statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class DeleteEndpoint extends Module::Endpoint
    @inheritProtected()
    # @implements Module::EndpointInterface
    @include CrudEndpointMixin
    @module Module

    @public init: Function,
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
        @error HTTP_NOT_FOUND
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @response null
        @summary "
          Hide the #{@itemEntityName}
        "
        @description "
          Hide the #{@itemEntityName}
          from the database.
        "

    @initialize()
