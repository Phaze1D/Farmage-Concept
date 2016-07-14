
require './PaperItem.tpl.jade'

class PaperItem extends BlazeComponent
  @register "PaperItem"

  onCreated: ->
    super
    @instant = @data().instant
    @animationType = @data().animationType
    @focusColor = if @data().focusColor? then @data().focusColor else '#eceff1'
    @unfocusColor = if @data().unfocusColor? then @data().unfocusColor else 'black'
    @classes = @data().classes

  toggleItem: (event) ->
    PI = @
    $back = $(event.target).closest('.paper-item').find('.item-back')
    @focus($back, event) if $back.css('right') isnt '0px'
    $('.item-back').each ->
      $this = $(@)
      if !($this.is($back)) && $this.attr('focused') is 'true'
        PI.unfocus($this)



  focus: ($target, event) ->
    $target.attr('focused', true)
    if @instant
      $target.css right: '0', left: '0'
    else
      if !@animationType? || @animationType is 1
        @animation1($target, event)
      else
        @animation2($target, event)


  animation1: ($target, event) ->
    left = event.offsetX
    right = event.target.clientWidth - left
    $target.css 'background-color': @focusColor
    $target.velocity(
      p:
        right: right
        left: left
      o:
        duration: 0
        easing: "ease-in-out"
    ).velocity(
      p:
        right: 0
        left: 0
      o:
        duration: 150
        easing: "ease-in-out"
    )

  animation2: ($target, events) ->
    $target.closest('.paper-item').css color: @focusColor

  unfocus: ($target) ->
    $target.css
      right: ''
      left: ''
      'background-color': @unfocusColor
    $target.closest('.paper-item').css color: @unfocusColor
    $target.attr('focused', false)

  events: ->
    super.concat
      'click .paper-item': @toggleItem
