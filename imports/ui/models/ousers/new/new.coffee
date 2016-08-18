require './new.jade'

class OUsersNew extends BlazeComponent
  @register 'ousersNew'

  constructor: (args) ->
    # body...


  onToggleGrid: (event) ->
    $(event.currentTarget).find('.js-toggle').trigger('click')

  


  events: ->
    super.concat
      'click .js-toggle-grid': @onToggleGrid
