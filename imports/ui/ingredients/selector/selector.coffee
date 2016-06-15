{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'


{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'


require './selector.html'


Template.IngredientsSelector.onCreated ->
  @ready = new ReactiveVar

  @subCallback =
    onStop: (err) ->
      console.log "selector ing stop #{err}"
    onReady: () ->

  @autorun =>
    new SimpleSchema(
      select:
        type: Function
    ).validate(@data)

    organ_id = FlowRouter.getParam('organization_id')
    handler = Meteor.subscribe 'ingredients', organ_id, 'organization', organ_id, @subCallback
    @ready.set handler.ready()



Template.IngredientsSelector.helpers
  ready: ->
    Template.instance().ready.get()

  ingredients:  ->
    organization = Organizations.findOne(FlowRouter.getParam('organization_id'))
    organization.ingredients()


Template.IngredientsSelector.events
  'click .js-ingredient-select': (event, instance) ->
    id = $(event.target).attr 'data-id'
    instance.data.select id
