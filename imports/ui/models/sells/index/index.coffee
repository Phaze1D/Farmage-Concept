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
      parent = FlowRouter.getQueryParam('parent')
      parent_id = FlowRouter.getQueryParam('parent_id')
      @page = Meteor.subscribeWithPagination "sells", organization_id, parent, parent_id,  @searchValue.get(), 9,
                onStop: (err) ->
                  console.log "sub stop #{err}"
                onReady: ->
      @pReady.set @page.ready()

  sells: ->
    SellModule.Sells.find({}, {sort: createdAt: -1})

  ready: ->
    if @page.ready()
      count = SellModule.Sells.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
