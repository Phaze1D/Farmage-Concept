IndexMixin = require '../../../mixins/index_mixin.coffee'
InventoryModule = require '../../../../api/collections/inventories/inventories.coffee'

require './index.jade'

class InventoriesIndex extends IndexMixin
  @register 'inventories.index'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @canLoadMore = true
    @autorun =>
        @page = Meteor.subscribeWithPagination "inventories", organization_id, 'organization', organization_id, 9,
                  onStop: (err) ->
                    console.log "sub stop #{err}"
                  onReady: ->

  inventories: ->
    InventoryModule.Inventories.find()

  ready: ->
    if @page.ready()
      count = InventoryModule.Inventories.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
