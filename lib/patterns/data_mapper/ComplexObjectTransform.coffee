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

# NOTE: от этого класса можно унаследовать отдельный класс с кастомным определением схемы и использовать его внутри объявления атрибутов рекорда

module.exports = (Module)->
  {
    FuncG, MaybeG, TupleG, SubsetG
    RecordInterface
    ObjectTransform
    Utils: { _, inflect, moment }
  } = Module::

  class ComplexObjectTransform extends ObjectTransform
    @inheritProtected()
    @module Module

    @public @static parseRecordName: FuncG(String, TupleG String, String),
      default: (asName)->
        if /.*[:][:].*/.test(asName)
          [vsModuleName, vsRecordName] = asName.split '::'
        else
          [vsModuleName, vsRecordName] = [@moduleName(), inflect.camelize inflect.underscore inflect.singularize asName]
        unless /(Record$)|(Migration$)/.test vsRecordName
          vsRecordName += 'Record'
        [vsModuleName, vsRecordName]

    @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
      default: (asName)->
        [vsModuleName, vsRecordName] = @parseRecordName asName
        (@Module.NS ? @Module::)[vsRecordName]

    @public @static @async normalize: FuncG([MaybeG Object], Object),
      default: (serialized)->
        unless serialized?
          yield return {}
        result = {}
        for own key, value of serialized
          result[key] = switch
            when _.isString(value) and moment(value, moment.ISO_8601).isValid()
              Module::DateTransform.normalizeSync value
            when _.isString value
              Module::StringTransform.normalizeSync value
            when _.isNumber value
              Module::NumberTransform.normalizeSync value
            when _.isBoolean value
              Module::BooleanTransform.normalizeSync value
            when _.isPlainObject(value) and /.{2,}[:][:].{2,}/.test value.type
              RecordClass = @findRecordByName value.type
              # NOTE: в правильном использовании вторым аргументом должна передаваться ссылка на коллекцию, то тут мы не можем ее получить
              # а так как рекорды в этом случае используются ТОЛЬКО для оформления структуры и хранения данных внутри родительского рекорда, то коллекции физически просто нет.
              yield RecordClass.normalize value
            when _.isPlainObject value
              yield Module::ComplexObjectTransform.normalize value
            when _.isArray value
              yield Module::ComplexArrayTransform.normalize value
            else
              Module::Transform.normalizeSync value
        yield return result

    @public @static @async serialize: FuncG([MaybeG Object], Object),
      default: (deserialized)->
        unless deserialized?
          yield return {}
        result = {}
        for own key, value of deserialized
          result[key] = switch
            when _.isString value
              Module::StringTransform.serializeSync value
            when _.isNumber value
              Module::NumberTransform.serializeSync value
            when _.isBoolean value
              Module::BooleanTransform.serializeSync value
            when _.isDate value
              Module::DateTransform.serializeSync value
            when _.isObject(value) and /.{2,}[:][:].{2,}/.test value.type
              RecordClass = @findRecordByName value.type
              yield RecordClass.serialize value
            when _.isPlainObject value
              yield Module::ComplexObjectTransform.serialize value
            when _.isArray value
              yield Module::ComplexArrayTransform.serialize value
            else
              Module::Transform.serializeSync value
        yield return result

    @public @static objectize: FuncG([MaybeG Object], Object),
      default: (deserialized)->
        unless deserialized?
          return {}
        result = {}
        for own key, value of deserialized
          result[key] = switch
            when _.isString value
              Module::StringTransform.objectize value
            when _.isNumber value
              Module::NumberTransform.objectize value
            when _.isBoolean value
              Module::BooleanTransform.objectize value
            when _.isDate value
              Module::DateTransform.objectize value
            when _.isObject(value) and /.{2,}[:][:].{2,}/.test value.type
              RecordClass = @findRecordByName value.type
              RecordClass.objectize value
            when _.isPlainObject value
              Module::ComplexObjectTransform.objectize value
            when _.isArray value
              Module::ComplexArrayTransform.objectize value
            else
              Module::Transform.objectize value
        return result


    @initialize()
