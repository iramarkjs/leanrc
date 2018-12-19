

# методы `parseQuery` и `executeQuery` должны быть реализованы в миксинах в отдельных подлючаемых npm-модулях т.к. будут содержать некоторый платформозависимый код.


module.exports = (Module)->
  {
    FuncG, UnionG, MaybeG
    QueryInterface
    CursorInterface
    Interface
  } = Module::

  class QueryableCollectionInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @async deleteBy: FuncG Object

    @virtual @async destroyBy: FuncG Object
    # NOTE: обращается к БД
    @virtual @async removeBy: FuncG Object

    @virtual @async findBy: FuncG [Object, MaybeG Object], CursorInterface
    # NOTE: обращается к БД
    @virtual @async takeBy: FuncG [Object, MaybeG Object], CursorInterface

    @virtual @async updateBy: FuncG [Object, Object]
    # NOTE: обращается к БД
    @virtual @async patchBy: FuncG [Object, Object]

    @virtual @async exists: FuncG Object, Boolean

    @virtual @async query: FuncG [UnionG Object, QueryInterface], CursorInterface

    @virtual @async parseQuery: FuncG(
      [UnionG Object, QueryInterface]
      UnionG Object, String, QueryInterface
    )

    @virtual @async executeQuery: FuncG(
      [UnionG Object, String, QueryInterface]
      CursorInterface
    )


    @initialize()