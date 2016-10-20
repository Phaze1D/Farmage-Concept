IndexMixin = require '../../../mixins/index_mixin.coffee'
CustomerModule = require '../../../../api/collections/customers/customers.coffee'

require './index.jade'

class CustomersIndex extends IndexMixin
  @register 'customers.index'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @canLoadMore = true
    @autorun =>
      @page = Meteor.subscribeWithPagination "customers", organization_id, 'organization', organization_id, @searchValue.get(), 9,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

      @pReady.set @page.ready()


  customers: ->
    CustomerModule.Customers.find({}, {sort: first_name: 1})

  ready: ->
    if @page.ready()
      count = CustomerModule.Customers.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
