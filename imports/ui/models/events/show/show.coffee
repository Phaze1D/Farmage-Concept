ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class EventShow extends ShowMixin
  @register 'EventShow'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "event.parents", organization_id, @data().event._id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  onRendered: ->
    super

  tabs: ->
    ['Information']

  type: ->
    st = @data().event.for_type
    st.charAt(0).toUpperCase() + st.slice(1);

  identifer: ->
    @data().event.for_doc()
