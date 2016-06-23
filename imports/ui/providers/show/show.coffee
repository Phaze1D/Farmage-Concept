{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
ProviderModule = require '../../../api/collections/providers/providers.coffee'

require './show.html'

Template.ProvidersShow.onCreated ->




Template.ProvidersShow.helpers
  provider: () ->
    ProviderModule.Providers.findOne(FlowRouter.getParam 'child_id')

  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
