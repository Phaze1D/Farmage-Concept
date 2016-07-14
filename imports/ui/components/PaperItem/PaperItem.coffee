
require './PaperItem.tpl.jade'

class PaperItem extends BlazeComponent
  @register "PaperItem"

  onCreated: ->
    super
    @instant = @data().instant

  toggleItem: (event) ->
    PI = @
    $back = $(event.target).closest('.paper-item').find('.item-back')
    @focus($back, event)
    $('.item-back').each ->
      $this = $(@)
      if !($this.is($back)) && $this.css('right') is '0px'
        PI.unfocus($this)



  focus: ($target, event) ->
    if @instant
      $target.css right: '0', left: '0'
    else
      left = event.offsetX
      right = event.target.clientWidth - left
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


  unfocus: ($target) ->
    $target.css right: '', left: ''



  events: ->
    super.concat
      'click .paper-item': @toggleItem
