

require './index.jade'

class OrganizationsIndex extends BlazeComponent
  @register 'organizations.index'

  constructor: (args) ->

  onCreated: ->
    super
    @expanded = new ReactiveVar(false)

  onRendered: ->
    super


  onShow: (event) ->
    @expanded.set true
    $('.js-show-right').trigger('click')
    $('.js-right-content').css opacity: 1

    $(@find('.new-action')).velocity
      p:
        scaleX: 0
        scaleY : 0
      o:
        duration: 125



  onHide: (event) ->
    $(@find('.new-action')).velocity 'reverse'

    $('.js-right-content').velocity
      p:
        opacity: 0
      o:
        duration: 350
        complete: =>
          @expanded.set false




  events: ->
    super.concat
      'click .js-show-new': @onShow
      'click .js-hide-new': @onHide
