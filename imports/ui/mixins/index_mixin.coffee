
class IndexMixin extends BlazeComponent

  constructor: (args) ->
    super

  onCreated: ->
    super
    @cardExpand = new ReactiveVar(false)
    @rightShown = new ReactiveVar(false)
    @size = 1
    @ticking = false

  onRendered: ->
    super


  onShow: (event) ->
    @parentComponent().data().hasFAB = false
    @fabShrink()
    @rightShown.set true
    $('.js-show-right').trigger('click')
    rootphp = $('#root-paper-header-panel')
    rootphp.removeClass('touchScroll')
    rootphp.css overflow: 'hidden' if window.innerWidth < 1023


  onHide: (event) ->
    @parentComponent().data().hasFAB = true
    @fabExpand() unless @cardExpand.get()



  onCardExpand: (event) ->
    @cardExpand.set true
    @fabShrink() unless @rightShown.get()

  onCardShrink: (event) ->
    @cardExpand.set false
    @fabExpand() unless @rightShown.get()


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
        @rightShown.set false
        rootphp = $('#root-paper-header-panel')
        rootphp.addClass('touchScroll')
        rootphp.css overflow: ''


  events: ->
    super.concat
      'click .js-show-new': @onShow
      'click .js-hide-new': @onHide
      'click .card-expand-action': @onCardExpand
      'click .card-shrink-action': @onCardShrink


module.exports = IndexMixin
