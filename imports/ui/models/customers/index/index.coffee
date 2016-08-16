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
    @autorun =>
      @subscribe "customers", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->


  customers: ->
    CustomerModule.Customers.find()
