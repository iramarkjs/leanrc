
module.exports = (Module)->
  Module.defineMixin Module::Record, (BaseClass) ->
    class CucumberEntryMixin extends BaseClass
      @inheritProtected()

      # Place for attributes and computeds definitions
      @attribute name: String
      @attribute description: String


    CucumberEntryMixin.initializeMixin()