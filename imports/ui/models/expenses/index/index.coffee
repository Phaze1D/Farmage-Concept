IndexMixin = require '../../../mixins/index_mixin.coffee'
ExpenseModule = require '../../../../api/collections/expenses/expenses.coffee'


require './index.jade'

class ExpensesIndex extends IndexMixin
  @register 'expenses.index'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "expenses", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->


  onRendered: ->
    super


  expenses: ->
    ExpenseModule.Expenses.find()
