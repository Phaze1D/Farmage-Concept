ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class InventoryShow extends ShowMixin
  @register 'InventoryShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information']
