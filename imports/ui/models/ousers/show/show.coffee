ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class OUserShow extends ShowMixin
  @register 'OUserShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information']
