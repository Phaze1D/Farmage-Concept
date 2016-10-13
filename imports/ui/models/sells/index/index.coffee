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
    @canLoadMore = true
    @autorun =>
        @page = Meteor.subscribeWithPagination "sells", organization_id, 'organization', organization_id, 9,
                  onStop: (err) ->
                    console.log "sub stop #{err}"
                  onReady: ->

  sells: ->
    SellModule.Sells.find()

  ready: ->
    if @page.ready()
      count = SellModule.Sells.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
