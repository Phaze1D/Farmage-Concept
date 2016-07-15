
require './PaperRipple.tpl.jade'

class PaperRipple extends BlazeComponent
  @register "PaperRipple"

  constructor: (args) ->
    super

  onCreated: ->
    super
    @mouseD = false
    @fill = @data().fill
    @classes = @data().classes
    @touchDuration = 1000




  rippleAnimation: (event) ->
    @mouseD = true
    x            = event.offsetX
    y            = event.offsetY
    w            = event.target.offsetWidth
    h            = event.target.offsetHeight
    offsetX      = Math.abs( (w / 2) - x )
    offsetY      = Math.abs( (h / 2) - y )
    deltaX       = (w / 2) + offsetX
    deltaY       = (h / 2) + offsetY
    scale_ratio  = Math.sqrt(Math.pow(deltaX, 2) + Math.pow(deltaY, 2))

    $(event.target).find('.ripple-obj').css(fill: @fill)
    ripple = $(event.target).find('.js-ripple')
    ripple.velocity 'stop'
    ripple.velocity(
      p:
        translateX: x
        translateY: y
        transformOrigin: '50% 50%'
        scale: 0
        opacity: 0.8
      o:
        duration: 0
    ).velocity(
      p:
        scale: scale_ratio
        opacity: 0
      o:
        duration: 300
        easing: "easeOutSine"
    )


  events: ->
    super.concat
      'click .js-ripple-action': @rippleAnimation
