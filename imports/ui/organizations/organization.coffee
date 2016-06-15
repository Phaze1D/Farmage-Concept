{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

{ SubSchema } = require '../../api/shared/sub_schema.coffee'


OrganizationModule = require '../../api/collections/organizations/organizations.coffee'

require './show/show.coffee'
require './update/update.coffee'

require './organization.html'

Template.OrganizationT.onCreated ->
  @autorun =>
    SubSchema.validate(@data)


Template.OrganizationT.helpers
  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')

  oView: () ->
    data = Template.instance().data
    if data.update?
      'OrganizationUpdate'
    else
      'OrganizationShow'
