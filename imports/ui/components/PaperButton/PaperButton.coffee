
require './PaperButton.tpl.jade'


class PaperButton extends BlazeComponent
  @register 'PaperButton'

  constructor: (args) ->

  onCreated: ->
    super
    @raise = @data().raise
    @data().classes += ' elevation-1' if @raise


  onRendered: ->

  down: (event) ->
    target = $(event.target)
    target = target.closest('button.paper-button') unless target.is('button.paper-button')
    if @raise
      target.toggleClass('elevation-2')


  up: (event) ->
    target = $(event.target)
    target = target.closest('button.paper-button') unless target.is('button.paper-button')
    if @raise
      target.removeClass('elevation-2')


  events: ->
    super.concat
      'mousedown': @down
      'mouseup': @up
      'mouseout': @up
