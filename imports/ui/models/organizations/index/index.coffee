

require './index.jade'

class OrganizationsIndex extends BlazeComponent
  @register 'organizations.index'

  constructor: (args) ->

  onCreated: ->
    super
    @expanded = new ReactiveVar(false)

  onRendered: ->
    super


  onExpand: (event) ->
    @expanded.set(true)

    Meteor.setTimeout =>
      @changeDimensions($(event.currentTarget))
    , 250


  changeDimensions: (floatB) ->
    floatB.css 'box-shadow': 'none'
    hypo = parseInt Math.sqrt Math.pow($('#paper-header-main')[0].clientHeight - 38, 2) +
                              Math.pow($('#paper-header-main')[0].clientWidth - 38, 2)
    floatB.velocity
      p:
        width: hypo * 2
        height: hypo * 2
        opacity: 0
        translateX: '50%'
        translateY: '50%'
      o:
        duration: 350
        easing: 'linear'





    floatB.find('.plus-icon-div').css visibility: 'hidden'



  onShrinked: (event) ->
    @expandedClass.set('card-expand-action')
    @iconClass.set('add')
    @expanded.set(false)




  events: ->
    super.concat
      'click .new-action': @onExpand
