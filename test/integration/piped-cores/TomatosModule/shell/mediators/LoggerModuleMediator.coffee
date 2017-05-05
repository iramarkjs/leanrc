# Это может быть сторонний модуль, который может подключаться как Cucumbers
{LoggerApplication} = require('../../logger')::


module.exports = (Module) ->
  {
    Mediator
    Pipes
    Application
    ApplicationFacade
  } = Module::
  {
    CONNECT_MODULE_TO_LOGGER
    CONNECT_SHELL_TO_LOGGER
  } = Application::
  {
    PipeAwareInterface
    PipeAwareModule
    Pipe
  } = Pipes::
  {
    STDIN
    STDOUT
    STDLOG
    STDSHELL
  } = PipeAwareModule

  class LoggerModuleMediator extends Mediator
    @inheritProtected()
    @Module: Module

    @public logger: PipeAwareInterface,
      get: -> @getViewComponent()

    @public listNotificationInterests: Function,
      default: -> [
        CONNECT_MODULE_TO_LOGGER
        CONNECT_SHELL_TO_LOGGER
      ]

    @public handleNotification: Function,
      default: (aoNotification)->
        switch aoNotification.getName()
          # Connect any Module's STDLOG to the logger's STDIN
          when CONNECT_MODULE_TO_LOGGER
            module = aoNotification.getBody()
            pipe = Pipe.new()
            module.acceptOutputPipe STDLOG, pipe
            @logger.acceptInputPipe STDIN, pipe
            break
          # Bidirectionally connect shell and logger on STDLOG/STDSHELL
          when CONNECT_SHELL_TO_LOGGER
            # The junction was passed from ShellJunctionMediator
            junction = aoNotification.getBody()

            # Connect the shell's STDLOG to the logger's STDIN
            shellToLog = junction.retrievePipe STDLOG
            @logger.acceptInputPipe STDIN, shellToLog

            # Connect the logger's STDSHELL to the shell's STDIN
            logToShell = Pipe.new()
            shellIn = junction.retrievePipe STDIN
            shellIn.connectInput logToShell
            @logger.acceptOutputPipe STDSHELL, logToShell
            break

    @public init: Function,
      default: ->
        @super LoggerModuleMediator.name, LoggerApplication.new()


  LoggerModuleMediator.initialize()