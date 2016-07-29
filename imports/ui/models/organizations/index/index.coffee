

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
    $(@find('.new-action')).velocity
      p:
        scaleX: 0
        scaleY : 0
      o:
        duration: 125



  onHide: (event) ->
    $(@find('.new-action')).velocity 'reverse'



  events: ->
    super.concat
      'click .js-show-new': @onShow
      'click .js-hide-new': @onHide
