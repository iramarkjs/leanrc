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
    FuncG, InterfaceG
    GatewayInterface
    CrudEndpointMixin
    Endpoint
    Utils: { statuses }
  } = Module::

  UNAUTHORIZED      = statuses 'unauthorized'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class ListEndpoint extends Endpoint
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
        @response @listSchema, "
          The #{@listEntityName}.
        "
        @error UNAUTHORIZED
        @error UPGRADE_REQUIRED
        @summary "
          List of filtered #{@listEntityName}
        "
        @description  "
          Retrieves a list of filtered
          #{@listEntityName} by using query.
        "
        return


    @initialize()
