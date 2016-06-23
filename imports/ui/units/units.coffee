{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

{ SubSchema } = require '../../api/shared/sub_schema.coffee'

OrganizationModule = require '../../api/collections/organizations/organizations.coffee'


require './index/index.coffee'
require './new/new.coffee'
require './update/update.coffee'
require './show/show.coffee'

require './units.html'

Template.UnitsT.onCreated ->
  @ready = new ReactiveVar(false)

  @subCallback =
    onStop: (err) ->
      console.log "units sub stop #{err}"
    onReady: () ->

  @autorun =>
    SubSchema.validate(@data)

    organ_id = FlowRouter.getParam('organization_id')
    parent = FlowRouter.getQueryParam('parent')
    parent_id = FlowRouter.getQueryParam('parent_id')
    handler = Meteor.subscribe 'units', organ_id, parent, parent_id, @subCallback
    @ready.set handler.ready()



Template.UnitsT.helpers
  ready: () ->
    Template.instance().ready.get()

  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')

  sView: () ->
    data = Template.instance().data
    return 'UnitsShow'    if data.show?
    return 'UnitsUpdate'  if data.update?
    return 'UnitsNew'     if data.new?
    return 'UnitsIndex'
