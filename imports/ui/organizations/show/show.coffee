{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OC = require '../../../api/collections/organizations/organizations.coffee'
OMethods = require '../../../api/collections/organizations/methods.coffee'

require './show.html'


Template.OrganizationShow.onCreated ->
  

Template.OrganizationShow.onRendered ->

Template.OrganizationShow.onDestroyed ->


Template.OrganizationShow.helpers
  organization: ->
    OC.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')

  permission: ->
    organ = OC.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
    organ.hasUser(Meteor.userId()).permission if organ?



Template.OrganizationShow.events
