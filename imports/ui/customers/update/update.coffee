{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

{ SubSchema } = require '../../../api/shared/sub_schema.coffee'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
CustomerModule = require '../../../api/collections/customers/customers.coffee'


require './update.html'

Template.CustomersUpdate.onCreated ->
  
