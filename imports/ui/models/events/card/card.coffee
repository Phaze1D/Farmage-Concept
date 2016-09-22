CardEvents = require '../../../mixins/card_events_mixin.coffee'

require './card.jade'

class EventCard extends BlazeComponent
  @register 'EventCard'

  mixins: -> [
    CardEvents
  ]

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "event.parents", organization_id, @data().event._id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  isManual: ->
    if @data().event.is_user_event
      'on'
    else
      'off'

  forType: ->
    st = @data().event.for_type
    st.charAt(0).toUpperCase() + st.slice(1);

  identifer: ->
    name = @data().event.for_doc().fetch()[0].name
    if name? then name else @data().event.for_id

  date: (date) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

  createdBy: ->
    @data().event.created_by().fetch()[0]

  createdByEmail: ->
    @data().event.created_by().fetch()[0].emails[0].address

  showTitle: ->
    "Event For #{@forType()}"
