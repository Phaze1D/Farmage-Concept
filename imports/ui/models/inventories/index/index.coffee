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
      parent = FlowRouter.getQueryParam('parent')
      parent_id = FlowRouter.getQueryParam('parent_id')
      @page = Meteor.subscribeWithPagination "inventories", organization_id, parent, parent_id,  @searchValue.get(), 9,
                onStop: (err) ->
                  console.log "sub stop #{err}"
                onReady: ->
      @pReady.set @page.ready()

  inventories: ->
    InventoryModule.Inventories.find({}, {sort: createdAt: -1})

  ready: ->
    if @page.ready()
      count = InventoryModule.Inventories.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
