{ Meteor } = require 'meteor/meteor'
OrganizationModule = require '../../organizations/organizations.coffee'

Meteor.publish "yields", (organization_id) ->
  organization = OrganizationModule.Organizations.findOne(organization_id)

  if @userId? && organization.hasUser(@userId)
    return organization.yields()
  else
    @ready();