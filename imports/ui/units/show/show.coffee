{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
UnitModule = require '../../../api/collections/units/units.coffee'

require './show.html'

Template.UnitsShow.onCreated ->




Template.UnitsShow.helpers
  unit: () ->
    UnitModule.Units.findOne(FlowRouter.getParam 'child_id')

  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
