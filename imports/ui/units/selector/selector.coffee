{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'


{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'


require './selector.html'


Template.UnitsSelector.onCreated ->
  @ready = new ReactiveVar

  @subCallback =
    onStop: (err) ->
      console.log "selector unit stop #{err}"
    onReady: () ->

  @autorun =>
    new SimpleSchema(
      select:
        type: Function
    ).validate(@data)

    organ_id = FlowRouter.getParam('organization_id')
    handler = Meteor.subscribe 'units', organ_id, 'organization', organ_id, @subCallback
    @ready.set handler.ready()



Template.UnitsSelector.helpers
  ready: ->
    Template.instance().ready.get()

  units:  ->
    organization = Organizations.findOne(FlowRouter.getParam('organization_id'))
    organization.units()

  organization: ->
    Organizations.findOne(FlowRouter.getParam('organization_id'))


Template.UnitsSelector.events
  'click .js-unit-select': (event, instance) ->
    id = $(event.target).attr 'data-id'
    instance.data.select id
