{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

{ SubSchema } = require '../app/sub_schema.coffee'

OrganizationModule = require '../../api/collections/organizations/organizations.coffee'


require './sells.html'

Template.SellsT.onCreated ->
  @ready = new ReactiveVar(false)

  @subCallback =
    onStop: (err) ->
      console.log "sells sub stop #{err}"
    onReady: () ->

  @autorun =>
    SubSchema.validate(@data)

    organ_id = FlowRouter.getParam('organization_id')
    parent = FlowRouter.getQueryParam('parent')
    parent_id = FlowRouter.getQueryParam('parent_id')
    handler = Meteor.subscribe 'sells', organ_id, parent, parent_id, @subCallback
    @ready.set handler.ready()



Template.SellsT.helpers
  ready: () ->
    Template.instance().ready.get()

  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')

  sView: () ->
    data = Template.instance().data
    return 'SellsShow'    if data.show?
    return 'SellsUpdate'  if data.update?
    return 'SellsNew'     if data.new?
    return 'SellsIndex'
