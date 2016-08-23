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
    @autorun =>
      @subscribe "inventories", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  inventories: ->
    InventoryModule.Inventories.find()
