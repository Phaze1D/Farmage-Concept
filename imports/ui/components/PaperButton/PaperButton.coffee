
require './PaperButton.tpl.jade'


class PaperButton extends BlazeComponent
  @register 'PaperButton'

  constructor: (args) ->

  onCreated: ->
    super
    @data().rippleFill = 'lightgrey' unless @data().rippleFill?


  onRendered: ->

  down: (event) ->
    unless @data().disabled
      target = $(@find('.paper-button'))
      if @data().raise isnt 0
        target.addClass("elevation-#{@data().elevation + 1}")
      if @data().callbacks? and @data().callbacks.down?
        @data().callbacks.down()


  up: (event) ->
    unless @data().disabled
      target = $(event.target)
      target = target.closest('.paper-button') unless target.is('.paper-button')
      if @data().raise isnt 0
        target.removeClass("elevation-#{@data().elevation + 1}")

      if @data().callbacks? and @data().callbacks.up?
        @data().callbacks.up()



  events: ->
    super.concat
      'mousedown .paper-button': @down
      'mouseup .paper-button': @up
      'mouseout .paper-button': @up
