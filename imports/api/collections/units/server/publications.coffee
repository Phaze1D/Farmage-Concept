{ Meteor } = require 'meteor/meteor'
OrganizationModule = require '../../organizations/organizations.coffee'

Meteor.publish "units", (organization_id) ->
  organization = OrganizationModule.Organizations.findOne(organization_id)

  if @userId? && organization.hasUser(@userId)
    return organization.units()
  else
    @ready();
