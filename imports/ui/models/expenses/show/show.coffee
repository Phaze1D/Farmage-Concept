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
    @autorun =>
      @parentComponent().parentComponent().parentComponent().rightData.set
        update_id: @data().expense._id
        provider_id: @data().expense.provider_id
        unit_id: @data().expense.unit_id


  tabs: ->
    ['Information']

  totalCost: ->
    @data().expense.price * @data().expense.quantity

  unit: ->
    @data().expense.unit().fetch()[0]

  provider: ->
    if @data().expense.provider_id?
      @data().expense.provider().fetch()[0]
