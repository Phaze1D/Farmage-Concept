{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

{ SubSchema } = require '../app/sub_schema.coffee'

OrganizationModule = require '../../api/collections/organizations/organizations.coffee'
CustomerModule = require '../../api/collections/customers/customers.coffee'

require './index/index.coffee'
require './new/new.coffee'

require './customers.html'

Template.CustomersT.onCreated ->
  @ready = new ReactiveVar(false)

  @subCallback =
    onStop: (err) ->
      console.log "customers sub stop #{err}"
    onReady: () ->

  @autorun =>
    SubSchema.validate(@data)

    organ_id = FlowRouter.getParam('organization_id')
    parent = FlowRouter.getQueryParam('parent')
    parent_id = FlowRouter.getQueryParam('parent_id')
    handler = Meteor.subscribe 'customers', organ_id, parent, parent_id, @subCallback
    @ready.set handler.ready()



Template.CustomersT.helpers
  ready: () ->
    Template.instance().ready.get()

  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')

  cView: () ->
    data = Template.instance().data
    return 'CustomersShow'    if data.show?
    return 'CustomersUpdate'  if data.update?
    return 'CustomersNew'     if data.new?
    return 'CustomersIndex'