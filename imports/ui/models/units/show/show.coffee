ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class UnitShow extends ShowMixin
  @register 'UnitShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information']
