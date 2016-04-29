{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

exports.BelongsOrganizationSchema =
  new SimpleSchema([
    organization_id:
      type: String
      index: true
      denyUpdate: true
  ])
