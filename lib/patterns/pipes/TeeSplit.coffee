RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::TeeSplit extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::PipeFittingInterface

    @Module: LeanRC

    iplOutputs = @protected outputs: Array

    @public connect: Function,
      default: (aoOutput)->
        @[iplOutputs] ?= []
        @[iplOutputs].push aoOutput
        return yes

    @public disconnect: Function,
      default: ->
        @[iplOutputs] ?= []
        return @[iplOutputs].pop()

    @public disconnectFitting: Function,
      args: [LeanRC::PipeFittingInterface]
      return: LeanRC::PipeFittingInterface
      default: (aoTarget)->
        voRemoved = null
        @[iplOutputs] ?= []
        for aoOutput, i in @[iplOutputs]
          if aoOutput is aoTarget
            @[iplOutputs].splice i,1
            voRemoved = aoOutput
            break
        voRemoved

    @public write: Function,
      default: (aoMessage)->
        vbSuccess = yes
        @[iplOutputs].forEach (aoOutput)->
          unless aoOutput.write aoMessage
            vbSuccess = no
        vbSuccess

    constructor: (output1=null, output2=null)->
      super arguments...
      if output1?
        @connect output1
      if output2?
        @connect output2


  return LeanRC::TeeSplit.initialize()
