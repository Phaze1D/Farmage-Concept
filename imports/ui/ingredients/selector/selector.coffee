{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'


{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'


require './selector.html'


Template.IngredientsSelector.onCreated ->
  organ_id = FlowRouter.getParam('organization_id')

  @subCallback =
    onStop: (err) ->
      console.log "selector ing stop #{err}"
    onReady: () ->

  @autorun =>
    new SimpleSchema(
      select:
        type: Function
    ).validate(@data)
    @subscribe 'ingredients', organ_id, 'organization', organ_id, @subCallback


Template.IngredientsSelector.helpers
  ingredients:  ->
    organization = Organizations.findOne(FlowRouter.getParam('organization_id'))
    return false if organization.ingredients().count() <= 0
    organization.ingredients()


Template.IngredientsSelector.events
  'click .js-ingredient-select': (event, instance) ->
    id = $(event.target).attr 'data-id'
    instance.data.select id
