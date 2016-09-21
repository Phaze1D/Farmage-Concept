ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class IngredientShow extends ShowMixin
  @register 'IngredientShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information', 'Analytics', 'Reports']
