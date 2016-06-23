{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'

require './show.html'

Template.OUsersShow.onCreated ->


Template.OUsersShow.helpers
  ouser: () ->
    organ = OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    organ.hasUser(FlowRouter.getParam 'child_id')

  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')

  hasUser: (user) ->
    organization = OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    organization.hasUser(user._id)
