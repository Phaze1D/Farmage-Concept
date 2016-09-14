require './card.jade'

class EventCard extends BlazeComponent
  @register 'EventCard'

  constructor: (args) ->
    # body...

  isManual: ->
    if @data().event.is_user_event
      'on'
    else
      'off'

  forType: ->
    st = @data().event.for_type
    st.charAt(0).toUpperCase() + st.slice(1);

  identifer: ->
    @data().event.for_id

  date: (date) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"
