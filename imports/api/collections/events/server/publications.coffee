{ Meteor } = require 'meteor/meteor'
OrganizationModule = require '../../organizations/organizations.coffee'

Meteor.publish "events", (organization_id) ->
  organization = OrganizationModule.Organizations.findOne(organization_id)

  if @userId? && organization.hasUser(@userId)
    return organization.events()
  else
    @ready();
