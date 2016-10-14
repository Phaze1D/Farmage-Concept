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
    @canLoadMore = true
    @autorun =>
      parent = FlowRouter.getQueryParam('parent')
      parent_id = FlowRouter.getQueryParam('parent_id')
      @page = Meteor.subscribeWithPagination "yields", organization_id, parent, parent_id, 9,
                onStop: (err) ->
                  console.log "sub stop #{err}"
                onReady: ->

  yields: ->
    YieldModule.Yields.find({}, {sort: createdAt: -1})

  ready: ->
    if @page.ready()
      count = YieldModule.Yields.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
