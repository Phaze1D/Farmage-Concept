
require './PaperHeaderPanel.tpl.jade'
require './PaperHeader.tpl.jade'
require './PaperHeaderMain.tpl.jade'


class PaperHeaderPanel extends BlazeComponent
  @register('PaperHeaderPanel')

  constructor: (args) ->
    @throttle = @throttle.bind(@)


  onCreated: ->
    super



  onRendered: ->
    super
    @smallH = $(@find "##{@data().id}-paper-header-small")
    @lastP = 0
    @dChange = position: 0, time: 0
    @goingDown = true
    @showed = false

    main = document.getElementById("#{@data().id}-paper-header-panel")
    main.addEventListener('scroll', @throttle)

  throttle: (e) ->
    unless @ticking
      window.requestAnimationFrame( () =>
        @onScroll(e)
        @ticking = false
      )
    @ticking = true;

  showSmall: (duration) ->
    duration = if duration > 250 then 250 else duration
    @showed = true
    @smallH.velocity
      p:
        top: ['0', '-64px']
      o:
        duration: duration


  hideSmall: (duration) ->
    duration = if duration > 250 then 250 else duration
    @showed = false
    @smallH.velocity
      p:
        top: '-64px'
      o:
        duration: duration


  onScroll: (event) ->
    yPosition = event.target.scrollTop

    if yPosition > 212
      if yPosition > @lastP
        unless @goingDown
          @dChange.position = yPosition
          @dChange.time = event.timeStamp
        @goingDown = true

      else
        if @goingDown
          @dChange.position = yPosition
          @dChange.time = event.timeStamp
        @goingDown = false


      if !@goingDown && yPosition < @dChange.position - 64 && !@showed
        @showSmall event.timeStamp - @dChange.time

      if @goingDown && yPosition > @dChange.position + 64 && @showed
        @hideSmall event.timeStamp - @dChange.time

    if yPosition < 148 && @showed
      @hideSmall(0)

    @lastP = yPosition



  # events: ->
  #   super.concat
  #     "scroll ##{@data().id}-paper-header-panel": @onScroll
