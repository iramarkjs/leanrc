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

# комманда эквивалентная контролеру в рельсах
# в зависимости от сингала, будет запускаться нужный ресурс CucumbersResource
# а в зависимости от типа нотификейшена внутри инстанса ресурса
# будет выполняться нужный экшен (метод) create, update, detail, list, delete

# в случае со стрим-сервером заливку и отдачу файла будет реализовывать платформозависимый код медиатора, а ресурсная команда Uploads этим заниматься не будет. (чтобы медиатор напрямую писал в нужный прокси, и считывал поток так же напрямую из прокси.)

module.exports = (Module)->
  {
    AnyT
    FuncG, UnionG, TupleG, MaybeG, DictG, StructG, EnumG, ListG
    CollectionInterface, ContextInterface
    Interface
  } = Module::

  class ResourceInterface extends Interface
    @inheritProtected()
    @module Module

    # @virtual needsLimitation: Boolean
    # @virtual entityName: String
    # @virtual keyName: String
    # @virtual itemEntityName: String
    # @virtual listEntityName: String
    # @virtual collectionName: String
    # @virtual collection: CollectionInterface
    #
    # @virtual context: MaybeG ContextInterface
    # @virtual listQuery: MaybeG Object
    # @virtual recordId: MaybeG String
    # @virtual recordBody: MaybeG Object


    @virtual @static actions: DictG String, Object
    @virtual @static action: FuncG [UnionG Object, TupleG Object, Object]


    @virtual @async list: FuncG [], StructG {
      meta: StructG pagination: StructG {
        limit: UnionG Number, EnumG ['not defined']
        offset: UnionG Number, EnumG ['not defined']
      }
      items: ListG Object
    }
    @virtual @async detail: FuncG [], Object
    @virtual @async create: FuncG [], Object
    @virtual @async update: FuncG [], Object
    @virtual @async delete: Function
    @virtual @async destroy: Function

    @virtual @async doAction: FuncG [String, ContextInterface], AnyT
    @virtual @async writeTransaction: FuncG [String, ContextInterface], Boolean
    @virtual @async saveDelayeds: Function


    @initialize()
