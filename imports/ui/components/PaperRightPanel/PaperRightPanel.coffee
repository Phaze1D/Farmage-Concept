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
    if !@wide && window.innerWidth >= 1024 && @opened
      @wide = true
      @showSmall()

    if @wide && window.innerWidth < 1024 && @opened
      @wide = false
      @showFull()


  onShow: (event) ->
    if window.innerWidth >= 1024
      @showSmall()
    else
      @showFull()

  showSmall:  ->
    @opened = true
    @rightPanel.velocity
      p:
        width: (window.innerWidth * .35).toFixed(0)
        right: 0
      o:
        duration: 350
        easing: 'ease-in-out'
        complete: =>
          @rightPanel.css width: '35%'


  showFull: ->
    @opened = true
    $('#scrim').css 'z-index': 1
    $('#scrim').addClass('show').removeClass('hide')
    $("#paper-drawer-main").removeClass('move-foward').addClass('move-back')
    @rightPanel.velocity
      p:
        width: window.innerWidth
        right: 0
      o:
        duration: 350
        easing: 'ease-in-out'
        complete: =>
          @rightPanel.css width: '100%'


  onHide: (event) ->
    if window.innerWidth >= 1024
      @hideSmall()
    else
      @hideFull()


  hideSmall: ->
    @opened = false
    @rightPanel.velocity
      p:
        right: (-@rightPanel.width()).toFixed(0)
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: =>
          @rightPanel.css width: '35%'
          @rightPanel.css right: '-35%'


  hideFull: ->
    @opened = false
    $('#scrim').addClass('hide').removeClass('show')
    $("#paper-drawer-main").removeClass('move-back').addClass('move-foward')
    @rightPanel.velocity
      p:
        right: (-@rightPanel.width()).toFixed(0)
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: =>
          $('#scrim').css 'z-index': 2
          @rightPanel.css width: '100%'
          @rightPanel.css right: '-100%'






  events: ->
    super.concat
      'click .js-show-right': @onShow
      'click .js-hide-right': @onHide
