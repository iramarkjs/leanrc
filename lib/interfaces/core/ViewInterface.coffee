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
    ANY
    FuncG, UnionG, MaybeG
    ObserverInterface
    NotificationInterface
    ControllerInterface
    MediatorInterface
    Interface
  } = Module::

  class ViewInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual registerObserver: FuncG [String, ObserverInterface]
    @virtual removeObserver: FuncG [String, UnionG ControllerInterface, MediatorInterface]
    @virtual notifyObservers: FuncG NotificationInterface
    @virtual registerMediator: FuncG MediatorInterface
    @virtual retrieveMediator: FuncG String, MaybeG MediatorInterface
    @virtual removeMediator: FuncG String, MaybeG MediatorInterface
    @virtual hasMediator: FuncG String, Boolean


    @initialize()
