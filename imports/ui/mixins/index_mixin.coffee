
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
    @parentComponent().data().hasFAB = false
    @fabShrink()
    @expanded.set true
    $('.js-show-right').trigger('click')
    if window.innerWidth < 1023
      $('#root-paper-header-panel').css overflow: 'hidden'


  onHide: (event) ->
    @parentComponent().data().hasFAB = true
    @fabExpand()
    $('#root-paper-header-panel').css overflow: ''


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
