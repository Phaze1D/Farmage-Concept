
require './PaperButton.tpl.jade'


class PaperButton extends BlazeComponent
  @register 'PaperButton'

  constructor: (args) ->

  onCreated: ->
    super
    @data().rippleFill = 'lightgrey' unless @data().rippleFill?


  onRendered: ->

  down: (event) ->
    target = $(event.target)
    target = target.closest('.paper-button') unless target.is('.paper-button')
    if @data().raise isnt 0
      target.addClass("elevation-#{@data().raise + 1}")


  up: (event) ->
    target = $(event.target)
    target = target.closest('.paper-button') unless target.is('.paper-button')
    if @data().raise isnt 0
      target.removeClass("elevation-#{@data().raise + 1}")


  events: ->
    super.concat
      'mousedown .paper-button': @down
      'mouseup .paper-button': @up
      'mouseout .paper-button': @up
