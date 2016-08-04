
OrganizationModule = require '../../../../api/collections/organizations/organizations.coffee'

require './index.jade'

class OrganizationsIndex extends BlazeComponent
  @register 'organizations.index'

  constructor: (args) ->

  onCreated: ->
    super
    @expanded = new ReactiveVar(false)

  onRendered: ->
    super

  organizations: ->
    OrganizationModule.Organizations.find()

  founder: (organization) ->
    Meteor.users.findOne organization.founder().user_id

  onShow: (event) ->
    @expanded.set true
    $('.js-show-right').trigger('click')
    $('.js-right-content').css opacity: 1
    @fabShrink()

  onHide: (event) ->
    @fabExpand()
    $('.js-right-content').velocity
      p:
        opacity: 0
      o:
        duration: 350
        complete: =>
          @expanded.set false

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


  events: ->
    super.concat
      'click .js-show-new': @onShow
      'click .js-hide-new': @onHide
      'click .card-expand-action': @fabShrink
      'click .card-shrink-action': @fabExpand
