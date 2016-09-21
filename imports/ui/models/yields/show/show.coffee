ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class YieldShow extends ShowMixin
  @register 'YieldShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information', 'Analytics', 'Reports']
