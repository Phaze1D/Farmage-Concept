
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
    target = target.closest('.paper-button') unless target.is('.paper-button')
    if @raise
      target.addClass('elevation-2')


  up: (event) ->
    target = $(event.target)
    target = target.closest('.paper-button') unless target.is('.paper-button')
    if @raise
      target.removeClass('elevation-2')


  events: ->
    super.concat
      'mousedown .paper-button': @down
      'mouseup .paper-button': @up
      'mouseout .paper-button': @up
