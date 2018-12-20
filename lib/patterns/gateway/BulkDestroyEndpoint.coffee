

module.exports = (Module)->
  {
    FuncG, InterfaceG
    GatewayInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses }
  } = Module::

  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class BulkDestroyEndpoint extends Endpoint
    @inheritProtected()
    @include CrudEndpointMixin
    @module Module

    @public init: FuncG(InterfaceG(gateway: GatewayInterface)),
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
        @queryParam 'query', @querySchema, "
          The query for finding
          #{@listEntityName}.
        "
        @response null
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @summary "
          Remove of filtered #{@listEntityName}
        "
        @description  "
          Remove a list of filtered
          #{@listEntityName} by using query.
        "
        return


    @initialize()
