
class IndexMixin extends BlazeComponent

  constructor: (args) ->
    super

  onCreated: ->
    super
    @cardExpand = new ReactiveVar(false)
    @rightShown = new ReactiveVar(false)
    @rightTemplate = new ReactiveVar("")
    @rightData = new ReactiveVar()
    @size = 1
    @ticking = false
    @searchValue = new ReactiveVar(null)

  onRendered: ->
    super

  search: (value) ->
    @searchValue.set value

  clearSearch: ->
    @searchValue.set null

  onShow: (event) ->
    @parentComponent().data().hasFAB = false
    @rightTemplate.set $(event.currentTarget).find('.plus-icon-div').attr('data-template')
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
        rootphp.css overflow: '' unless @cardExpand.get()


  onAction: (event) ->
    a = $(event.currentTarget).find('a')
    params = {}

    params.organization_id = a.attr('data-organ') if a.attr('data-organ')?
    params.child_id = a.attr('data-child') if a.attr('data-child')?

    FlowRouter.go a.attr('href'), params


  events: ->
    super.concat
      'click .js-show-new': @onShow
      'click .js-hide-new': @onHide
      'click .card-expand-action': @onCardExpand
      'click .card-shrink-action': @onCardShrink
      'click .js-action': @onAction


module.exports = IndexMixin
