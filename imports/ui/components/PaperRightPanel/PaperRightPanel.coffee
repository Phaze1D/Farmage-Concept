require './PaperRightPanel.tpl.jade'


class PaperRightPanel extends BlazeComponent
  @register 'PaperRightPanel'

  constructor: (args) ->
    @throttle = @throttle.bind(@)
    @ticking = false

  onRendered: ->
    @headerMain = $('#paper-header-main')
    @rightPanel = $('#paper-right-panel')
    @opened = false
    @wide = if window.innerWidth >= 1024 then true else false
    window.addEventListener 'resize', @throttle

  onDestroyed: ->
    super
    window.removeEventListener 'resize', @throttle


  throttle: (e) ->
    unless @ticking
      window.requestAnimationFrame( () =>
        @handleResize()
        @ticking = false
      )
    @ticking = true;


  handleResize: ->



  onShow: (event) ->
    if window.innerWidth >= 1024
      @showSmall()
    else
      @showFull()

  showSmall:  ->
    @rightPanel.velocity
      p:
        width: window.innerWidth * .35
        right: 0
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: =>
          @rightPanel.css width: '35%'


  showFull: ->


  onHide: (event) ->





  events: ->
    super.concat
      'click .js-show-right': @onShow
      'click .js-hide-right': @onHide
