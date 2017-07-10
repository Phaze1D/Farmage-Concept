require './timestamp.jade'

class Timestamp extends BlazeComponent
  @register 'Timestamp'

  constructor: (args) ->
    # body...

  date: (date) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

  createdBy: ->
    @data().item.created_by().fetch()[0]

  createdByEmail: ->
    @data().item.created_by().fetch()[0].emails[0].address
