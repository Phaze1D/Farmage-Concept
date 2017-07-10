
require './PaperRipple.tpl.jade'

class PaperRipple extends BlazeComponent
  @register "PaperRipple"

  constructor: (args) ->
    super

  onCreated: ->
    super
    @mouseD = false
    @touchDuration = 1000


  onRendered: ->
    super



  rippleAnimation: (event, eoffsetX, eoffsetY) ->

    eoffsetX = if event.offsetX? then event.offsetX else eoffsetX
    eoffsetY = if event.offsetY? then event.offsetY else eoffsetY

    @mouseD = true

    rio = $(event.target).find('.ripple-obj')
    rio.css(fill: @data().fill)

    ripple = $(event.target).find('.js-ripple')
    ripple.velocity 'stop'
    ripple.velocity(
      p:
        translateZ: '0'
        translateX: eoffsetX
        translateY: eoffsetY
        transformOriginX: '1px'
        transformOriginY: '1px'
        scale: 0
        opacity: 0.5
      o:
        duration: 0

    ).velocity
      p:
        scale: Math.sqrt(Math.pow((event.target.offsetWidth / 2) +
               Math.abs( (event.target.offsetWidth / 2) - eoffsetX ), 2) +
               Math.pow((event.target.offsetHeight / 2) +
               Math.abs( (event.target.offsetHeight / 2) - eoffsetY ), 2))
      o:
        duration: 250
        easing: "linear"




  opacityAnimation: (event) ->
    if @mouseD
      @mouseD = false
      $(event.target).find('.js-ripple').velocity
        p:
          opacity: [0, .5]
        o:
          duration: 350
          easing: "linear"
          queue: false




  events: ->
    super.concat
      'mousedown .js-ripple-action': @rippleAnimation
      'mouseup .js-ripple-action': @opacityAnimation
      # 'mouseout .js-ripple-action': @opacityAnimation
