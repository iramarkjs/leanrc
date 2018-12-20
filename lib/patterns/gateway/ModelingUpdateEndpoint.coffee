

module.exports = (Module)->
  {
    FuncG, InterfaceG
    GatewayInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses, joi }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class ModelingUpdateEndpoint extends Endpoint
    @inheritProtected()
    @include CrudEndpointMixin
    @module Module

    @public init: FuncG(InterfaceG(gateway: GatewayInterface)),
      default: (args...) ->
        @super args...
        @pathParam 'v', @versionSchema
        @header 'Authorization', joi.string().required(), "
          Authorization header for internal services.
        "
        @body @itemSchema.required(), "
          The data to replace the
          #{@itemEntityName} with.
        "
        @response @itemSchema, "
          The replaced #{@itemEntityName}.
        "
        @error HTTP_NOT_FOUND
        @error HTTP_CONFLICT
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @summary "
          Replace the #{@itemEntityName}
        "
        @description "
          Replaces an existing
          #{@itemEntityName} with the
          request body and returns the new document.
        "
        return


    @initialize()
