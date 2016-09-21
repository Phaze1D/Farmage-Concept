ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class EventShow extends ShowMixin
  @register 'EventShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information']
