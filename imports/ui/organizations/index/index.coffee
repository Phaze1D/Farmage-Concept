{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'


require './index.html'


Template.OrganizationsIndex.onCreated ->
  

Template.OrganizationsIndex.helpers

  organizations: () ->
    Organizations.find()
