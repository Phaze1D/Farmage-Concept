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
    @canLoadMore = true
    @autorun =>
        @page = Meteor.subscribeWithPagination "expenses", organization_id, 'organization', organization_id, 12,
                  onStop: (err) ->
                    console.log "sub stop #{err}"
                  onReady: ->


  onRendered: ->
    super


  expenses: ->
    ExpenseModule.Expenses.find()

  ready: ->
    if @page.ready()
      count = ExpenseModule.Expenses.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
