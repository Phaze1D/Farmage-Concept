
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
    ripple.animate 'stop'
    ripple.animate(
      {
        translateZ: '0'
        translateX: eoffsetX
        translateY: eoffsetY
        transformOriginX: '50%'
        transformOriginY: '50%'
        scale: 0
        opacity: 0.8
      },
      {
        duration: 0
      }
    ).animate(
      {
        scale: Math.sqrt(Math.pow((event.target.offsetWidth / 2) +
               Math.abs( (event.target.offsetWidth / 2) - eoffsetX ), 2) +
               Math.pow((event.target.offsetHeight / 2) +
               Math.abs( (event.target.offsetHeight / 2) - eoffsetY ), 2))
      },
      {
        duration: 250
        easing: "easeOutSine"
      }
    )


  opacityAnimation: (event) ->
    if @mouseD
      @mouseD = false
      $(event.target).find('.js-ripple').animate(
        {
          opacity: [0, .8]
        },
        {
          duration: 450
          easing: "easeOutSine"
          queue: false
        }
      )


  events: ->
    super.concat
      'mousedown .js-ripple-action': @rippleAnimation
      'mouseup .js-ripple-action': @opacityAnimation
      'mouseout .js-ripple-action': @opacityAnimation
