IndexMixin = require '../../../mixins/index_mixin.coffee'
SellModule = require '../../../../api/collections/sells/sells.coffee'


require './index.jade'

class SellsIndex extends IndexMixin
  @register 'sells.index'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "sells", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  sells: ->
    SellModule.Sells.find()
