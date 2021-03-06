require './PaperRightPanel.tpl.jade'


class PaperRightPanel extends BlazeComponent
  @register 'PaperRightPanel'

  constructor: (args) ->
    @shown = false

  onRendered: ->
    @headerMain = $("#paper-drawer-main")
    @headerSmall = $('#root-paper-header-small')
    @rightPanel = $('#paper-right-panel')
    @adSearch = $('.filter-area')

    # Missing on window resize event


  onShow: (event) ->
    unless @shown
      @shown = true
      if window.innerWidth >= 1024
        @showSmall()
      else
        @showFull()


  showSmall:  ->
    @rightPanel.velocity
      p:
        translateX: ['0', '100%']
      o:
        mobileHA: false
        duration: 350
        easing: 'ease-in-out'
        complete: =>
          @rightPanel.css(transform: '')
          if @data().callbacks? && @data().callbacks.showCallBack?
            @data().callbacks.showCallBack()

    @headerMain.velocity
      p:
        'padding-right': '35%'
      o:
        mobileHA: false
        duration: 350
        easing: 'ease-in-out'

    @headerSmall.addClass('right-opened')
    @adSearch.addClass('right-opened')




  showFull: ->
    $('#scrim').css 'z-index': 1
    $('#scrim').addClass('mshow').removeClass('mhide')
    @headerMain.css 'padding-right': '0'
    @rightPanel.velocity
      p:
        translateX: ['0', '100%']
      o:
        mobileHA: false
        duration: 350
        easing: 'ease-in-out'
        complete: =>
          @rightPanel.css(transform: '')
          @headerMain.removeClass('move-foward').addClass('move-back')
          if @data().callbacks? && @data().callbacks.showCallBack?
            @data().callbacks.showCallBack()


  onHide: (event) ->
    if @shown
      @shown = false
      if window.innerWidth >= 1024
        @hideSmall()
      else
        @hideFull()


  hideSmall: ->
    @rightPanel.velocity
      p:
        translateX: '100%'
      o:
        mobileHA: false
        duration: 250
        easing: 'ease-in-out'
        complete: =>
          if @data().callbacks? && @data().callbacks.hideCallBack?
            @data().callbacks.hideCallBack()

    @headerMain.velocity
      p:
        'padding-right': 0
      o:
        mobileHA: false
        duration: 250
        easing: 'ease-in-out'

    @headerSmall.removeClass('right-opened')
    @adSearch.removeClass('right-opened')



  hideFull: ->
    @headerMain.css 'padding-right': '0'
    $('#scrim').addClass('mhide')
    @headerMain.removeClass('move-back').addClass('move-foward')
    @rightPanel.velocity
      p:
        translateX: '100%'
      o:
        mobileHA: false
        duration: 250
        easing: 'ease-in-out'
        complete: =>
          $('#scrim').removeClass('show')
          $('#scrim').css 'z-index': 2

          if @data().callbacks? && @data().callbacks.hideCallBack?
            @data().callbacks.hideCallBack()



  events: ->
    super.concat
      'click .js-show-right': @onShow
      'click .js-hide-right': @onHide
