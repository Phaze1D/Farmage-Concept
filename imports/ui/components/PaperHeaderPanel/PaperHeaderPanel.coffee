
require './PaperHeaderPanel.tpl.jade'
require './PaperHeader.tpl.jade'
require './PaperHeaderMain.tpl.jade'


class PaperHeaderPanel extends BlazeComponent
  @register('PaperHeaderPanel')

  constructor: (args) ->
    @lastY = 0
    @yChange = 1
    @ticking = false
    @down = false
    @goingUp = false
    @crossed = false


    @throttle = @throttle.bind(@)

  onRendered: ->
    super
    main = document.getElementById('paper-drawer-main')
    main.addEventListener('scroll', @throttle)

  throttle: (e) ->
    unless @ticking
      window.requestAnimationFrame( () =>
        @scrolling(e.target.scrollTop)
        @ticking = false
      )
    @ticking = true;

  scrolling: (yPosition) ->
    mainY = yPosition

    if @lastY < yPosition
      if @goingUp
        @yChange = yPosition + 100
        @startTime = Date.now()
      @goingUp = false
    else
      unless @goingUp
        @startTime = Date.now()
        @yChange = (yPosition - 100)
      @goingUp =  true


    if yPosition > 212 + 148
      if @down && !@goingUp && yPosition > @yChange
        duration = Date.now() - @startTime
        @moveUp duration #move up if going down

      if !@down && @goingUp && yPosition < @yChange
        duration = Date.now() - @startTime
        @moveDown duration #move down if going up


    smallY = if yPosition > 148 then 148 else yPosition
    if smallY < 149
      $('#header-small').css transform: "translate3d(0px, #{smallY}px, 0px)"

    if yPosition < 212 || @lastY < 212
      header = $('#paper-header')
      if @goingUp && yPosition > 148 && @down
        header.css transform: "translate3d(0px, -148px, 0px)"
      else
        header.addClass('elevation-0').removeClass('elevation-2')
        mainY = if mainY > 212 then 212 else mainY
        header.css transform: "translate3d(0px, -#{mainY}px, 0px)"
        @down = false

    @lastY = yPosition

  moveDown: (duration) ->
    unless @down
      duration = if duration > 200 then 200 else duration
      @down = true
      header = $('#paper-header')
      header.addClass('elevation-2').removeClass('elevation-0')
      header.velocity
        p:
          translateY: ["-148px", "-212px"]
        o:
          duration: duration

  moveUp: (duration) ->
    if @down
      duration = if duration > 200 then 200 else duration
      @down = false
      header = $('#paper-header')
      header.velocity
        p:
          translateY: "-212px"
        o:
          duration: duration
          complete: ->
            header.addClass('elevation-0').removeClass('elevation-2')
