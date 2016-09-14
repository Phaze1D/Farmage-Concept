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
    @autorun =>
      @subscribe "events", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->


  onRendered: ->
    super


  mEvents: ->
    EventModule.Events.find()
