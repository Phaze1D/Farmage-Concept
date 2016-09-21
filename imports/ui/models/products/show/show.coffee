ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class ProductShow extends ShowMixin
  @register 'ProductShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information', 'Analytics', 'Reports']
