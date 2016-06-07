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
  @organization = new ReactiveVar


  @autorun =>
    organ = OC.Organizations.findOne(_id: FlowRouter.getParam 'id')
    @organization.set(organ)
    

Template.OrganizationShow.onRendered ->

Template.OrganizationShow.onDestroyed ->


Template.OrganizationShow.helpers
  organization: ->
    Template.instance().organization.get()

  permission: ->
    Template.instance().organization.get().hasUser(Meteor.userId()).permission



Template.OrganizationShow.events
