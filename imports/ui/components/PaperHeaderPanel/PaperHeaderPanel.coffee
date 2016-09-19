
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
    @fabFirst = true


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


  showFAB: ->
    if @data().hasFAB
      $('.new-action').velocity
        p:
          scaleX: 1
          scaleY : 1
        o:
          duration: 125


  hideFAB: ->
    if @data().hasFAB
      $('.new-action').velocity
        p:
          scaleX: 0
          scaleY : 0
        o:
          duration: 125


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


      if !@goingDown && yPosition < @dChange.position - 128 && !@showed
        @showSmall Date.now() - @dChange.time
        @showFAB()

      if @goingDown && yPosition > @dChange.position + 128 && @showed
        @hideSmall Date.now() - @dChange.time
        @hideFAB()

      if @goingDown && @fabFirst
        @hideFAB()
        @fabFirst = false

    if yPosition <= 168 && (@showed || !@fabFirst)
      @showFAB()
      @hideSmall(0)
      @fabFirst = true

    @lastP = yPosition



  events: ->
    super.concat
      "scroll ##{@data().id}-paper-header-panel": @onScroll
