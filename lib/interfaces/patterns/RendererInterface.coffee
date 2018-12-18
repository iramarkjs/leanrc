

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG, InterfaceG
    ContextInterface, ResourceInterface
    ProxyInterface
  } = Module::

  class RendererInterface extends ProxyInterface
    @inheritProtected()
    @module Module

    @virtual @async render: FuncG [ContextInterface, AnyT, ResourceInterface, MaybeG InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }], MaybeG AnyT


    @initialize()
