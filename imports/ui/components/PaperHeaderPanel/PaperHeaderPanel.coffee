
require './PaperHeaderPanel.tpl.jade'
require './PaperHeader.tpl.jade'
require './PaperHeaderMain.tpl.jade'


class PaperHeaderPanel extends BlazeComponent
  @register('PaperHeaderPanel')

  constructor: (args) ->
    @lastY = 0
    @fix = 0
    @ticking = false
    @crossed = false
    @down = false
    @startTime = 0

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
    if yPosition > 212
      mainY = 212
      @crossed = true


    if @lastY < yPosition
      @lastY = yPosition

    if yPosition > 212 && @lastY > yPosition && @fix is 0
      @fix = yPosition
      @startTime = Date.now()

    if yPosition > 212 && yPosition + 100 < @fix
      duration = Date.now() - @startTime
      @fix = 0
      @lastY = yPosition
      @moveDown(duration)




    smallY = if yPosition > 148 then 148 else yPosition
    $('#header-small').css transform: "translate3d(0px, #{smallY}px, 0px)"

    if yPosition < 212
      $('#paper-header').css transform: "translate3d(0px, -#{mainY}px, 0px)"
      @crossed = false



  moveDown: (duration) ->
    unless @down
      duration = if duration > 200 then 200 else duration
      @down = true
      $('#paper-header').velocity
        p:
          translateY: ["-148px", "-212px"]
        o:
          duration: duration

  moveUp: (duration) ->
