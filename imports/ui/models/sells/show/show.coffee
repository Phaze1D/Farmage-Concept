ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class SellShow extends ShowMixin
  @register 'SellShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information']
