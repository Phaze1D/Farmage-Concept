

class IndexMixin extends BlazeComponent

  constructor: (args) ->
    super
    @throttle = @throttle.bind(@)

  onCreated: ->
    super
    @expanded = new ReactiveVar(false)
    @size = 1
    @ticking = false

  onRendered: ->
    super
    Meteor.setTimeout( =>
      @resizeCard()
    , 200)

    window.addEventListener 'resize', @throttle


  throttle: ->
    unless @ticking
      window.requestAnimationFrame =>
        @resizeCard()
        @ticking = false;
    @ticking = true;


  onDestroyed: ->
    super
    window.removeEventListener 'resize', @throttle


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
      progressCallback: =>
        @resizeCard()

      showCallBack: =>
        @resizeCard()

      hideCallBack: =>
        @resizeCard()
        @expanded.set false


  resizeCard: ()->
    card = $(@findAll '.card-margin')
    mainContent = $(@find '.main-content')

    count = 0
    while count - 1 > 0 && mainContent.innerWidth() * ( 1/(count - 1)) < 290
      count--
      @size = count

    count = 0
    while mainContent.innerWidth() * ( 1/(count + 1) ) >= 290
      count++
      @size = count


    card.css width: "#{100/@size}%"


  events: ->
    super.concat
      'click .js-show-new': @onShow
      'click .js-hide-new': @onHide
      'click .card-expand-action': @onCardExpand
      'click .card-shrink-action': @onCardShrink


module.exports = IndexMixin
