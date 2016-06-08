{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../api/collections/organizations/organizations.coffee'

require './show/show.coffee'
require './update/update.coffee'

require './organization.html'

Template.OrganizationT.onCreated ->
  @autorun =>
    new SimpleSchema(
      'show':
        type: Object
        optional: true
      'show.id':
        type: String
        optional: true

      'update':
        type: Object
        optional: true
      'update.id':
        type: String
        optional: true


    ).validate(@data)


Template.OrganizationT.helpers
  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')

  oView: () ->
    data = Template.instance().data
    if data.update?
      'OrganizationUpdate'
    else
      'OrganizationShow'
