{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'

require './index.html'

Template.OUsersIndex.onCreated ->



Template.OUsersIndex.helpers
  ousers: () ->
    organization = OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    organization.o_users()

  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')

  hasUser: (user) ->
    organization = OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    organization.hasUser(user._id)
