ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class EventShow extends ShowMixin
  @register 'EventShow'

  constructor: (args) ->
    super

  onRendered: ->
    super
    @parentComponent().parentComponent().parentComponent().rightData.set
      update_id: @data().event._id
      for_id: @data().event.for_id
      for_type: @data().event.for_type

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

  amountTitle: ->
    if @data().event.amount > 0 then "Amount Added" else "Amount Taken"
