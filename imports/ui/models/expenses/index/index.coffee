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
      parent = FlowRouter.getQueryParam('parent')
      parent_id = FlowRouter.getQueryParam('parent_id')
      @page = Meteor.subscribeWithPagination "expenses", organization_id, parent, parent_id,  @searchValue.get(), 12,
                onStop: (err) ->
                  console.log "sub stop #{err}"
                onReady: =>
                  @sReady.set true


  onRendered: ->
    super


  expenses: ->
    ExpenseModule.Expenses.find({}, {sort: createdAt: -1})

  ready: ->
    if @page.ready()
      count = ExpenseModule.Expenses.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
