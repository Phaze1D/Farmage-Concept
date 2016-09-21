ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class ExpenseShow extends ShowMixin
  @register 'ExpenseShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information']
