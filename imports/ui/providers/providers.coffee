{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

{ SubSchema } = require '../../api/shared/sub_schema.coffee'

OrganizationModule = require '../../api/collections/organizations/organizations.coffee'

require './new/new.coffee'
require './index/index.coffee'
require './update/update.coffee'
require './show/show.coffee'

require './providers.html'


Template.ProvidersT.onCreated ->
  organ_id = FlowRouter.getParam('organization_id')
  parent = FlowRouter.getQueryParam('parent')
  parent_id = FlowRouter.getQueryParam('parent_id')

  @subCallback =
    onStop: (err) ->
      console.log "providers sub stop #{err}"
    onReady: () ->

  @autorun =>
    SubSchema.validate(@data)
    @subscribe 'providers', organ_id, parent, parent_id, @subCallback


Template.ProvidersT.helpers
  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')

  sView: () ->
    data = Template.instance().data
    return 'ProvidersShow'    if data.show?
    return 'ProvidersUpdate'  if data.update?
    return 'ProvidersNew'     if data.new?
    return 'ProvidersIndex'
