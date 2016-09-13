
require './PaperHeaderPanel.tpl.jade'
require './PaperHeaderSmall.tpl.jade'
require './PaperHeaderBig.tpl.jade'
require './PaperHeaderMain.tpl.jade'


class PaperHeaderPanel extends BlazeComponent
  @register('PaperHeaderPanel')

  constructor: (args) ->


  onCreated: ->
    super


  onRendered: ->
    super
    @smallH = $(@find "##{@data().id}-paper-header-small")
    @lastP = 0
    @dChange = position: 0, time: 0
    @goingDown = true
    @showed = false


  showSmall: (duration) ->
    duration = if duration > 350 then 350 else duration
    @showed = true
    @smallH.velocity
      p:
        top: ['0', '-70px']
      o:
        duration: duration


  hideSmall: (duration) ->
    duration = if duration > 350 then 350 else duration
    @showed = false
    @smallH.velocity
      p:
        top: '-70px'
      o:
        duration: duration


  onScroll: (event) ->
    yPosition = event.target.scrollTop

    if yPosition > 212
      if yPosition > @lastP
        unless @goingDown
          @dChange.position = yPosition
          @dChange.time = Date.now()
        @goingDown = true

      if yPosition < @lastP
        if @goingDown
          @dChange.position = yPosition
          @dChange.time = Date.now()
        @goingDown = false


      if !@goingDown && yPosition < @dChange.position - 64 && !@showed
        @showSmall Date.now() - @dChange.time

      if @goingDown && yPosition > @dChange.position + 64 && @showed
        @hideSmall Date.now() - @dChange.time

    if yPosition < 148 && @showed
      @hideSmall(0)

    @lastP = yPosition



  events: ->
    super.concat
      "scroll ##{@data().id}-paper-header-panel": @onScroll
