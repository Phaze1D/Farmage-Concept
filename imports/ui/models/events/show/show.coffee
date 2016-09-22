ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class EventShow extends ShowMixin
  @register 'EventShow'

  constructor: (args) ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information']

  type: ->
    st = @data().event.for_type
    st.charAt(0).toUpperCase() + st.slice(1);

  identifer: ->
    name = @data().event.for_doc().fetch()[0].name
    if name? then name else @data().event.for_id

  isManual: ->
    if @data().event.is_user_event then 'Yes' else 'No'

  date: (date) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

  createdBy: ->
    @data().event.created_by().fetch()[0]

  createdByEmail: ->
    @data().event.created_by().fetch()[0].emails[0].address

  amountTitle: ->
    if @data().event.amount > 0 then "Amount Added" else "Amount Taken"
