
require './PaperRipple.tpl.jade'

class PaperRipple extends BlazeComponent
  @register "PaperRipple"


  onCreated: ->
    super
    @mouseD = false
    @fill = @data().fill

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

    console.log @fill
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
      o:
        duration: 300
        easing: "easeOutSine"
    )


  opacityAnimation: (event) ->
    if @mouseD
      @mouseD = false
      ripple = $(event.target).find('.js-ripple')
      ripple.velocity(
        p:
          opacity: [0, .8]
        o:
          duration: 400
          easing: "easeOutSine"
          queue: false
      )


  events: ->
    super.concat
      'mousedown .js-ripple-action': @rippleAnimation
      'mouseup .js-ripple-action': @opacityAnimation
      'mouseout .js-ripple-action': @opacityAnimation
