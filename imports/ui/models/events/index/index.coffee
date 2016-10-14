IndexMixin = require '../../../mixins/index_mixin.coffee'
EventModule = require '../../../../api/collections/events/events.coffee'


require './index.jade'

class EventsIndex extends IndexMixin
  @register 'events.index'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @previous = 0
    @canLoadMore = true
    @autorun =>
      parent = FlowRouter.getQueryParam('parent')
      parent_id = FlowRouter.getQueryParam('parent_id')
      @page = Meteor.subscribeWithPagination "events", organization_id, parent, parent_id, 12,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  onRendered: ->
    super


  mEvents: ->
    EventModule.Events.find({}, {sort: createdAt: -1})

  ready: ->
    if @page.ready()
      count = EventModule.Events.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
