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
    @handleResize()


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

    $('#paper-drawer-main').velocity
      p:
        'padding-right': (window.innerWidth * .35).toFixed(0)
      o:
        duration: 350
        easing: 'ease-in-out'
        complete: =>
          $('#paper-drawer-main').css 'padding-right': '35%'


  showFull: ->
    @opened = true
    $('#scrim').css 'z-index': 1
    $('#scrim').addClass('show').removeClass('hide')
    $('#paper-drawer-main').css 'padding-right': '0'
    @rightPanel.velocity
      p:
        width: window.innerWidth
        right: 0
      o:
        duration: 350
        easing: 'ease-in-out'
        complete: =>
          $("#paper-drawer-main").removeClass('move-foward').addClass('move-back')
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

    $('#paper-drawer-main').velocity
      p:
        'padding-right': 0
      o:
        duration: 250
        easing: 'ease-in-out'



  hideFull: ->
    @opened = false
    $('#paper-drawer-main').css 'padding-right': '0'
    $('#scrim').addClass('hide')
    $("#paper-drawer-main").removeClass('move-back').addClass('move-foward')
    @rightPanel.velocity
      p:
        right: (-@rightPanel.width()).toFixed(0)
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: =>
          $('#scrim').removeClass('show')
          $('#scrim').css 'z-index': 2
          @rightPanel.css width: '100%'
          @rightPanel.css right: '-100%'



  onFocusIn: (event) ->
    $("#paper-header").css 'background-color': '#E0E0E0'
    $("#paper-header-main").css 'background-color': '#F5F5F5'
    $("#right-top").css 'background-color': '#eee'
    $('#paper-right-panel').css 'background-color': 'white'

  onFocusOut: (event) ->
    $("#paper-header").css 'background-color': '#EEE'
    $("#paper-header-main").css 'background-color': 'white'
    $("#right-top").css 'background-color': '#E0E0E0'
    $('#paper-right-panel').css 'background-color': '#F5F5F5'


  events: ->
    super.concat
      'click .js-show-right': @onShow
      'click .js-hide-right': @onHide
      # 'focusin #paper-right-panel': @onFocusIn
      # 'focusout #paper-right-panel': @onFocusOut
