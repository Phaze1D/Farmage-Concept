{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'


{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'


require './selector.html'


Template.CustomersSelector.onCreated ->
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
    handler = Meteor.subscribe 'customers', organ_id, 'organization', organ_id, @subCallback
    @ready.set handler.ready()



Template.CustomersSelector.helpers
  ready: ->
    Template.instance().ready.get()

  customers:  ->
    organization = Organizations.findOne(FlowRouter.getParam('organization_id'))
    return false if organization.customers().count() <= 0
    organization.customers()


Template.CustomersSelector.events
  'click .js-customer-select': (event, instance) ->
    id = $(event.target).attr 'data-id'
    instance.data.select id
