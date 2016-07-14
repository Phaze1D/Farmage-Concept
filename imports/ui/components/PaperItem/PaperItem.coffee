
require './PaperItem.tpl.jade'

class PaperItem extends BlazeComponent
  @register "PaperItem"

  onCreated: ->
    super
    @instant = @data().instant

  toggleItem: (event) ->
    PI = @
    $back = $(event.target).closest('.paper-item').find('.item-back')
    @focus $back
    $('.item-back').each ->
      $this = $(@)
      if !($this.is($back)) && $this.css('right') is '0px'
        PI.unfocus($this)



  focus: ($target) ->
    if @instant
      $target.css right: '0'
    else
      $target.velocity({right: '0'}, {duration: 150, easing: "ease-in-out"})


  unfocus: ($target) ->
    if @instant
      $target.css right: '100%'
    else
      $target.velocity({right: '100%'}, {duration: 150, easing: "ease-in-out"})


  events: ->
    super.concat
      'click .paper-item': @toggleItem
