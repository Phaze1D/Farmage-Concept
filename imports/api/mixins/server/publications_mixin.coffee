{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
OrganizationModule = require '../../collections/organizations/organizations.coffee'


module.exports.publicationInfo = (organization_id, parent, parent_id) ->
  new SimpleSchema(
    organization_id:
      type: String
    parent:
      type: String
      optional: true
    parent_id:
      type: String
      optional: true

  ).validate({organization_id, parent, parent_id})

  organization = OrganizationModule.Organizations.findOne(organization_id)

  parentDoc = organization                        if parent is "organization" || !parent? || parent is ''
  parentDoc = Meteor.users.findOne(parent_id)     if parent is 'user' && organization.hasUser(parent_id)

  ret =
    organization: organization
    parentDoc: parentDoc
