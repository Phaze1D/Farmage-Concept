

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
    Meteor.setTimeout =>
      @show()
    , 250


  show: ->
    $(@find('.shade')).addClass('show')
    $(@find('.new-action')).velocity
      p:
        scaleX: 0
        scaleY : 0
      o:
        duration: 125

    $('.organizations-new-div').velocity
      p:
        right: '0'
      o:
        duration: 250
        easing: 'ease-in-out'

    # if $(window).width() >= 1024
    #   $(@find('.organizations')).velocity
    #     p:
    #       'padding-right': '40%'
    #     o:
    #       duration: 250
    #       easing: 'ease-in-out'

  onHide: (event) ->
    Meteor.setTimeout =>
      @hide()
    , 250

  hide: ->
    shade = @find('.shade')
    $(shade).css opacity: '0'
    Meteor.setTimeout =>
      $(shade).css opacity: ''
      $(shade).removeClass('show')
    , 250


    $(@find('.new-action')).velocity 'reverse'

    $('.organizations-new-div').velocity
      p:
        right: if $(window).width() >= 1024 then '-40%' else '-100%'
      o:
        duration: 250
        easing: 'ease-in-out'
        complete: =>
          $('.organizations-new-div').css right: ''
          @expanded.set false









  events: ->
    super.concat
      'click .js-show-new': @onShow
      'click .js-hide-new': @onHide
