{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
InventoryModule = require '../../../api/collections/inventories/inventories.coffee'

require './show.html'

Template.InventoriesShow.onCreated ->




Template.InventoriesShow.helpers
  inventory: () ->
    InventoryModule.Inventories.findOne(FlowRouter.getParam 'child_id')

  organization: () ->
    OrganizationModule.Organizations.findOne(FlowRouter.getParam 'organization_id')
