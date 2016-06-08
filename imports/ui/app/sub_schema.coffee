{ SimpleSchema } = require 'meteor/aldeed:simple-schema'


module.exports.SubSchema =
  new SimpleSchema
    index:
      type: Boolean
      optional: true
      defaultValue: false
    new:
      type: Boolean
      optional: true
      defaultValue: false
    show:
      type: Boolean
      optional: true
    update:
      type: Boolean
      optional: true
