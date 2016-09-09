IndexMixin = require '../../../mixins/index_mixin.coffee'
YieldModule = require '../../../../api/collections/yields/yields.coffee'


require './index.jade'

class YieldsIndex extends IndexMixin
  @register 'yields.index'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "yields", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  yields: ->
    YieldModule.Yields.find()
