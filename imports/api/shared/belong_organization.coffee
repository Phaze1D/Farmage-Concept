{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

exports.BelongsOrganizationSchema =
  new SimpleSchema([
    organization_id:
      type: String
      index: true
      denyUpdate: true
  ])
