{ Meteor } = require 'meteor/meteor'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
OrganizationModule = require '../../organizations/organizations.coffee'


Meteor.publish "customers", (organization_id, parent, parent_id) ->
  new SimpleSchema(
    organization_id:
      type: String
    parent:
      type: String
      allowedValues: ['organization', 'user']
      defaultValue: 'organization'
      optional: true
    parent_id:
      type: String
      optional: true

  ).validate({organization_id, parent, parent_id})

  organization = OrganizationModule.Organizations.findOne(organization_id)

  parentDoc = organization                        if parent is "organization" || !parent?
  parentDoc = Meteor.users.findOne(parent_id)     if parent is 'user' && organization.hasUser(parent_id)


  # Missing permissions and pagenation
  if @userId? && organization? && organization.hasUser(@userId) && parentDoc?
    return parentDoc.customers()
  else
    @ready();
