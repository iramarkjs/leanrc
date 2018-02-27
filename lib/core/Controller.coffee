

module.exports = (Module)->
  {
    APPLICATION_MEDIATOR

    Facade
    Utils: { _ }
  } = Module::
  class Controller extends Module::CoreObject
    @inheritProtected()
    # @implements Module::ControllerInterface
    @module Module

    @const MULTITON_MSG: "Controller instance for this multiton key already constructed!"

    ipoView         = @private view: Module::ViewInterface
    iphCommandMap   = @private commandMap: Object
    iphClassNames   = @private classNames: Object
    ipsMultitonKey  = @protected multitonKey: String
    cphInstanceMap  = @private @static _instanceMap: Object,
      default: {}
    ipcApplicationModule = @protected ApplicationModule: Module::Class

    @public ApplicationModule: Module::Class,
      get: ->
        @[ipcApplicationModule] ?= if @[ipsMultitonKey]?
          Facade.getInstance @[ipsMultitonKey]
            ?.retrieveMediator APPLICATION_MEDIATOR
            ?.getViewComponent()
            ?.Module ? @Module
        else
          @Module

    @public @static getInstance: Function,
      args: [String]
      return: Module::Class
      default: (asKey)->
        unless Controller[cphInstanceMap][asKey]?
          Controller[cphInstanceMap][asKey] = Controller.new asKey
        Controller[cphInstanceMap][asKey]

    @public @static removeController: Function,
      args: [String]
      return: Module::Class
      default: (asKey)->
        if (voController = Controller[cphInstanceMap][asKey])?
          for asNotificationName in Reflect.ownKeys voController[iphCommandMap]
            voController.removeCommand asNotificationName
          Controller[cphInstanceMap][asKey] = undefined
          delete Controller[cphInstanceMap][asKey]
        return

    @public executeCommand: Function,
      default: (aoNotification)->
        vsName = aoNotification.getName()
        vCommand = @[iphCommandMap][vsName]
        unless vCommand?
          unless _.isEmpty vsClassName = @[iphClassNames][vsName]
            vCommand = @[iphCommandMap][vsName] = @ApplicationModule::[vsClassName]
        if vCommand?
          voCommand = vCommand.new()
          voCommand.initializeNotifier @[ipsMultitonKey]
          voCommand.execute aoNotification
        return

    @public registerCommand: Function,
      default: (asNotificationName, aCommand)->
        unless @[iphCommandMap][asNotificationName]
          @[ipoView].registerObserver asNotificationName, Module::Observer.new(@executeCommand, @)
          @[iphCommandMap][asNotificationName] = aCommand
        return

    @public lazyRegisterCommand: Function,
      default: (asNotificationName, asClassName)->
        unless @[iphCommandMap][asNotificationName]
          @[ipoView].registerObserver asNotificationName, Module::Observer.new(@executeCommand, @)
          @[iphClassNames][asNotificationName] = asClassName
        return

    @public hasCommand: Function,
      default: (asNotificationName)->
        @[iphCommandMap][asNotificationName]? or @[iphClassNames][asNotificationName]?

    @public removeCommand: Function,
      default: (asNotificationName)->
        if @hasCommand(asNotificationName)
          @[ipoView].removeObserver asNotificationName, @
          @[iphCommandMap][asNotificationName] = undefined
          @[iphClassNames][asNotificationName] = undefined
          delete @[iphCommandMap][asNotificationName]
          delete @[iphClassNames][asNotificationName]
        return

    @public initializeController: Function,
      args: []
      return: Module::NILL
      default: ->
        @[ipoView] = Module::View.getInstance @[ipsMultitonKey]

    @public init: Function,
      default: (asKey)->
        @super arguments...
        if Controller[cphInstanceMap][asKey]
          throw new Error Controller::MULTITON_MSG
        Controller[cphInstanceMap][asKey] = @
        @[ipsMultitonKey] = asKey
        @[iphCommandMap] = {}
        @[iphClassNames] = {}
        @initializeController()


  Controller.initialize()
