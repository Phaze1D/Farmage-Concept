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

  totalCost: ->
    @data().expense.price * @data().expense.quantity

  unit: ->
    @data().expense.unit().fetch()[0]

  provider: ->
    if @data().expense.provider_id?
      @data().expense.provider().fetch()[0]
