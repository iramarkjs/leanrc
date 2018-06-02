

module.exports = (Module)->
  {
    CoreObject
    Utils: { _, inflect, joi }
  } = Module::

  Module.defineMixin 'RecordMixin', (BaseClass = CoreObject) ->
    class extends BaseClass
      @inheritProtected()

      # конструктор принимает второй аргумент, ссылку на коллекцию.
      @public collection: Module::CollectionInterface

      ipoInternalRecord = @private internalRecord: Object # тип и формат хранения надо обдумать. Это инкапсулированные данные последнего сохраненного состояния из базы - нужно для функционала вычисления дельты изменений. (относительно изменений которые проведены над объектом но еще не сохранены в базе данных - хранилище.)

      @public @static schema: Object,
        default: {}
        get: (_data)->
          _data[@name] ?= do =>
            vhAttrs = {}
            for own asAttr, ahValue of @attributes
              vhAttrs[asAttr] = do (asAttr, ahValue)=>
                if _.isFunction ahValue.validate
                  ahValue.validate.call(@)
                else
                  ahValue.validate

            for own asAttr, ahValue of @computeds
              vhAttrs[asAttr] = do (asAttr, ahValue)=>
                if _.isFunction ahValue.validate
                  ahValue.validate.call(@)
                else
                  ahValue.validate
            joi.object vhAttrs
          _data[@name]

      @public @static parseRecordName: Function,
        default: (asName)->
          if /.*[:][:].*/.test(asName)
            [vsModuleName, vsRecordName] = asName.split '::'
          else
            [vsModuleName, vsRecordName] = [@moduleName(), inflect.camelize inflect.underscore inflect.singularize asName]
          unless /(Record$)|(Migration$)/.test vsRecordName
            vsRecordName += 'Record'
          [vsModuleName, vsRecordName]

      @public parseRecordName: Function,
        default: -> @constructor.parseRecordName arguments...

      @public @static findRecordByName: Function,
        args: [String]
        return: Module::Class
        default: (asName)->
          [vsModuleName, vsRecordName] = @parseRecordName asName
          (@Module.NS ? @Module::)[vsRecordName]

      @public findRecordByName: Function,
        args: [String]
        return: Module::Class
        default: (asName)->
          @constructor.findRecordByName asName

      #########################################################################

      # # под вопросом ??????
      # @public updateEdges: Function, [ANY], -> ANY # any type

      #########################################################################

      ###
        @customFilter ->
          reason:
            '$eq': (value)->
              # string of some aql code for example
            '$neq': (value)->
              # string of some aql code for example
      ###
      @public @static customFilters: Object,
        get: -> @metaObject.getGroup 'customFilters', no

      @public @static customFilter: Function,
        args: [Module::LAMBDA]
        return: Module::NILL
        default: (amStatementFunc)->
          config = amStatementFunc.call @
          for own asFilterName, aoStatement of config
            @metaObject.addMetaData 'customFilters', asFilterName, aoStatement
          return

      @public @static parentClassNames: Function,
        default: (AbstractClass = null)->
          AbstractClass ?= @
          SuperClass = Reflect.getPrototypeOf AbstractClass
          fromSuper = unless _.isEmpty SuperClass?.name
            @parentClassNames SuperClass
          _.uniq [].concat(fromSuper ? [])
            .concat [AbstractClass.name]

      @public @static attributes: Object,
        get: -> @metaObject.getGroup 'attributes', no
      @public @static edges: Object,
        get: -> @metaObject.getGroup 'edges', no
      @public @static computeds: Object,
        get: -> @metaObject.getGroup 'computeds', no

      @public @static attribute: Function,
        default: ->
          @attr arguments...
          return

      @public @static attr: Function,
        default: (typeDefinition, opts={})->
          [vsAttr] = Object.keys typeDefinition
          vcAttrType = typeDefinition[vsAttr]
          # NOTE: это всего лишь автоматическое применение трансформа, если он не указан явно. здесь НЕ надо автоматически подставить нужный рекорд или кастомный трансформ - они если должны использоваться, должны быть указаны вручную в схеме рекорда программистом.
          opts.transform ?= switch vcAttrType
            when String, Date, Number, Boolean, Array, Object
              -> Module::["#{vcAttrType.name}Transform"]
            # TODO: надо как то подставить в качестве трансформа рекорд, но вопрос КАК? (если when RecordInterface)
            # TODO: что делать, если в качестве трансформа идет кастомный трансформ???
            else
              -> Module::Transform
          opts.validate ?= -> opts.transform.call(@).schema
          {set} = opts
          opts.set = (aoData)->
            {value:voData} = opts.validate.call(@).validate aoData
            if _.isFunction set
              set.apply @, [voData]
            else
              voData
          if @attributes[vsAttr]?
            throw new Error "attribute `#{vsAttr}` has been defined previously"
          else
            @metaObject.addMetaData 'attributes', vsAttr, opts
            # NOTE: предыстория edges: в первых прототипах эта штука делалась для автоматизации создания графовой связи на основе id, сохраняемого из связи belongsTo. Метаданные об edges нужны были для того, чтобы автоматика при наличии айдишника сама создала нужную грань графа в отдельной специальной коллекции. От части это нужно было из-за того, что связи для обхода графа обязаны быть в отдельных таблицах, из-за того что они не могут быть "определены" через атрибуты в документе (аранга да и любая другая база поддерживает edge-индексы только на отдельной коллекции "связей")
            # естественно для связей М:М выделяется отдельная коллекция с отдельным рекордом описывающим структуру и нет никакой проблемы
            # однако в случае с "родительскими" связями например для рефферальной системы или для фолдерной - айдишник родительского объкта чаще всего содержится в отдельном атрибуте (а не выносится в отдельную коллекцию с дополнительным uniq-индексом для симуляции связей 1:М)
            @metaObject.addMetaData 'edges', vsAttr, opts if opts.through # TODO: решить вопрос с наличием такого понятия как edge - на данный момент они не используются нигде, либо надо довести их до ума и использовать, либо выпилить совсем.
          @public typeDefinition, opts
          return

      @public @static computed: Function,
        default: ->
          @comp arguments...
          return

      # TODO: надо определиться, зачем вообще отдельный тип определений computed
      # NOTE: изначальная задумка была в том, чтобы определять вычисляемые значения - НЕ ПРОМИСЫ! (т.е. некоторое значение, которое отправляется в респонзе реально не хранится в базе, но вычисляется НЕ асинхронной функцией-гетером)
      # NOTE: при этом компьютеду не надо указывать дополнительные специальные опшены типа `valuable` - потому что они по умолчанию обязаны сериализовываться и отправляться в ответах как реальные атрибуты
      # TODO: надо сделать так, чтобы в определении компьютеда в схеме отдельно значилось что он .forbidden() - т.е. присылать в запросе на сервер его нельзя, но с сервера в ответе он приходит. (возможно стоит восползоваться методом .strip() - он на валидации из output'а удаляет указанный ключ с значением)
      @public @static comp: Function,
        default: (args...)->
          [typeDefinition, ..., opts] = args
          if typeDefinition is opts
            typeDefinition = "#{opts.attr}": opts.attrType
          [vsAttr] = Object.keys typeDefinition
          vcAttrType = typeDefinition[vsAttr]
          # NOTE: это всего лишь автоматическое применение трансформа, если он не указан явно. здесь не надо автоматически подставить нужный рекорд или кастомный трансформ - они если должны использоваться, должны быть указаны вручную в схеме рекорда программистом.
          opts.transform ?= switch vcAttrType
            when String, Date, Number, Boolean, Array, Object
              -> Module::["#{vcAttrType.name}Transform"]
            # TODO: надо как то подставить в качестве трансформа рекорд, но вопрос КАК? (если when RecordInterface)
            # TODO: что делать, если в качестве трансформа идет кастомный трансформ???
            else
              -> Module::Transform
          opts.validate ?= -> opts.transform.call(@).schema.strip()
          unless opts.get?
            throw new Error 'getter `lambda` options is required'
          if opts.set?
            throw new Error 'setter `lambda` options is forbidden'
          if @computeds[vsAttr]?
            throw new Error "computed `#{vsAttr}` has been defined previously"
          else
            @metaObject.addMetaData 'computeds', vsAttr, opts
          @public typeDefinition, opts
          return

      @public @static new: Function,
        default: (aoAttributes, aoCollection)->
          aoAttributes ?= {}
          if aoAttributes.type?
            if @name is aoAttributes.type.split('::')[1]
              @super arguments...
            else
              RecordClass = @findRecordByName aoAttributes.type
              RecordClass?.new(aoAttributes, aoCollection) ? @super arguments...
          else
            aoAttributes.type = "#{@moduleName()}::#{@name}"
            @super aoAttributes, aoCollection

      @public @async save: Function,
        default: ->
          result = if yield @isNew()
            yield @create()
          else
            yield @update()
          return result

      @public @async create: Function,
        default: ->
          response = yield @collection.push @
          if response?
            { id } = response
            @id ?= id if id
          # vhAttributes = {}
          # for own key of @constructor.attributes
          #   vhAttributes[key] = @[key]
          # @[ipoInternalRecord] = vhAttributes
          @[ipoInternalRecord] = @constructor.objectize response
          yield return @

      @public @async update: Function,
        default: ->
          response = yield @collection.override @id, @
          # vhAttributes = {}
          # for own key of @constructor.attributes
          #   vhAttributes[key] = @[key]
          # @[ipoInternalRecord] = vhAttributes
          @[ipoInternalRecord] = @constructor.objectize response
          yield return @

      @public @async delete: Function,
        default: ->
          if yield @isNew()
            throw new Error 'Document is not exist in collection'
          @isHidden = yes
          @updatedAt = new Date()
          yield @save()

      @public @async destroy: Function,
        default: ->
          if yield @isNew()
            throw new Error 'Document is not exist in collection'
          yield @collection.remove @id
          return

      @public @virtual attributes: Function, # метод должен вернуть список атрибутов данного рекорда.
        args: []
        return: Array

      # NOTE: в оперативной памяти создается клон рекорда, НО с другим id
      @public @async clone: Function,
        default: -> yield @collection.clone @

      # NOTE: в коллекции создается копия рекорда, НО с другим id
      @public @async copy: Function,
        default: -> yield @collection.copy @

      @public @async decrement: Function,
        default: (asAttribute, step = 1)->
          unless _.isNumber @[asAttribute]
            throw new Error "doc.attribute `#{asAttribute}` is not Number"
          @[asAttribute] -= step
          yield @save()

      @public @async increment: Function,
        default: (asAttribute, step = 1)->
          unless _.isNumber @[asAttribute]
            throw new Error "doc.attribute `#{asAttribute}` is not Number"
          @[asAttribute] += step
          yield @save()

      @public @async toggle: Function,
        default: (asAttribute)->
          unless _.isBoolean @[asAttribute]
            throw new Error "doc.attribute `#{asAttribute}` is not Boolean"
          @[asAttribute] = not @[asAttribute]
          yield @save()

      @public @async touch: Function,
        default: ->
          @updatedAt = new Date()
          yield @save()

      @public @async updateAttribute: Function,
        default: (name, value)->
          @[name] = value
          yield @save()

      @public @async updateAttributes: Function,
        default: (aoAttributes)->
          for own vsAttrName, voAttrValue of aoAttributes
            do (vsAttrName, voAttrValue)=>
              @[vsAttrName] = voAttrValue
          yield @save()

      @public @async isNew: Function,
        default: ->
          return yes  unless @id?
          return not (yield @collection.includes @id)

      # TODO: надо реализовать, НО пока не понятно как перезагрузить все атрибуты этого же рекорда новыми значениями из базы данных?
      @public @async @virtual reload: Function,
        args: []
        return: Module::RecordInterface

      # TODO: не учтены установки значений, которые раньше не были установлены
      @public changedAttributes: Function,
        default: ->
          vhResult = {}
          for own vsAttrName, { transform } of @constructor.attributes
            voOldValue = @[ipoInternalRecord][vsAttrName]
            voNewValue = transform.call(@constructor).objectize @[vsAttrName]
            unless _.isEqual voNewValue, voOldValue
              vhResult[vsAttrName] = [voOldValue, voNewValue]
          vhResult

      @public resetAttribute: Function,
        default: (asAttribute)->
          { transform } = @constructor.attributes[asAttribute]
          @[asAttribute] = transform.call(@constructor).normalize @[ipoInternalRecord][asAttribute]
          return

      @public rollbackAttributes: Function,
        default: ->
          for own vsAttrName, { transform } of @constructor.attributes
            voOldValue = @[ipoInternalRecord][vsAttrName]
            @[vsAttrName] = transform.call(@constructor).normalize voOldValue
          return

      @public @static @async normalize: Function,
        default: (ahPayload, aoCollection)->
          unless ahPayload?
            return null
          vhAttributes = {}

          unless ahPayload.type?
            throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

          RecordClass = if @name is ahPayload.type.split('::')[1]
            @
          else
            @findRecordByName ahPayload.type

          for own asAttr, { transform } of RecordClass.attributes
            vhAttributes[asAttr] = yield transform.call(RecordClass).normalize ahPayload[asAttr]

          vhAttributes.type = ahPayload.type
          # NOTE: vhAttributes processed before new - it for StateMachine in record (when it has)

          voRecord = RecordClass.new vhAttributes, aoCollection
          # TODO: так как vhAttributes может содержать атрибуты сложных типов (массивы, объекты, другие рекорды), НО глубокого копирования не происходит, то в `ipoInternalRecord` атрибуты так же будут ссылаться на эти же структуры, а следовательно `changedAttributes`, `resetAttribute` и `rollbackAttributes` - не смогут отатить их изменения или вернуть дельты изменений
          # TODO: для того, чтобы `ipoInternalRecord` имел валидный слепок с рекорда, в него надо записывать результат objectize'а рекорда
          voRecord[ipoInternalRecord] = RecordClass.objectize voRecord
          yield return voRecord

      @public @static @async serialize:   Function,
        default: (aoRecord)->
          unless aoRecord?
            return null

          unless aoRecord.type?
            throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

          vhResult = {}
          for own asAttr, { transform } of aoRecord.constructor.attributes
            vhResult[asAttr] = yield transform.call(@).serialize aoRecord[asAttr]
          yield return vhResult

      @public @static objectize:   Function,
        default: (aoRecord)->
          unless aoRecord?
            return null

          unless aoRecord.type?
            throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

          vhResult = {}
          # for own asAttr, ahValue of aoRecord.constructor.attributes
          #   vhResult[asAttr] = do (asAttr, {transform} = ahValue)=>
          #     transform.call(@).objectize aoRecord[asAttr]
          for own asAttr, { transform } of aoRecord.constructor.attributes
            vhResult[asAttr] = transform.call(@).objectize aoRecord[asAttr]
          for own asAttr, { transform } of aoRecord.constructor.computeds
            vhResult[asAttr] = transform.call(@).objectize aoRecord[asAttr]
          vhResult

      @public @static @async restoreObject: Function,
        default: (Module, replica)->
          if replica?.class is @name and replica?.type is 'instance'
            Facade = Module::ApplicationFacade ? Module::Facade
            facade = Facade.getInstance replica.multitonKey
            collection = facade.retrieveProxy replica.collectionName
            if replica.isNew
              instance = collection.build replica.attributes
            else
              instance = yield collection.find replica.id
              for own vsAttrName, voAttrValue of replica.attributes
                instance[vsAttrName] = voAttrValue
            yield return instance
          else
            return yield @super Module, replica

      @public @static @async replicateObject: Function,
        default: (instance)->
          replica = yield @super instance
          ipsMultitonKey = Symbol.for '~multitonKey'
          replica.multitonKey = instance.collection[ipsMultitonKey]
          replica.collectionName = instance.collection.getProxyName()
          replica.isNew = yield instance.isNew()
          if replica.isNew
            replica.attributes = yield @objectize instance
          else
            replica.id = instance.id
            replica.attributes = instance.changedAttributes()
          yield return replica

      @public init: Function,
        default: (aoProperties, aoCollection) ->
          @super arguments...
          @collection = aoCollection
          { attributes } = @constructor
          for own vsAttrName, voAttrValue of aoProperties
            unless attributes[vsAttrName]?
              @[vsAttrName] = voAttrValue
          for own vsAttrName, { transform } of attributes
            voAttrValue = aoProperties[vsAttrName]
            @[vsAttrName] = transform.call(@constructor).normalize voAttrValue
          return

      @public toJSON: Function, { default: -> @constructor.objectize @ }


      @initializeMixin()
