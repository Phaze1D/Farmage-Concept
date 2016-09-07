
class IndexMixin extends BlazeComponent

  constructor: (args) ->
    super

  onCreated: ->
    super
    @expanded = new ReactiveVar(false)
    @size = 1
    @ticking = false

  onRendered: ->
    super


  onShow: (event) ->
    @fabShrink()
    @expanded.set true
    $('.js-show-right').trigger('click')


  onHide: (event) ->
    @fabExpand()


  onCardExpand: (event) ->
    @fabShrink() unless @expanded.get()

  onCardShrink: (event) ->
    @fabExpand() unless @expanded.get()


  fabShrink: (event) ->
    $(@find('.new-action')).velocity
      p:
        scaleX: 0
        scaleY : 0
      o:
        duration: 125

  fabExpand: (event) ->
    $(@find('.new-action')).velocity
      p:
        scaleX: 1
        scaleY : 1
      o:
        duration: 125

  rightCallbacks: ->
    ret =
      hideCallBack: =>
        @expanded.set false


  events: ->
    super.concat
      'click .js-show-new': @onShow
      'click .js-hide-new': @onHide
      'click .card-expand-action': @onCardExpand
      'click .card-shrink-action': @onCardShrink


module.exports = IndexMixin
