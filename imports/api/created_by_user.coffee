{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

exports.CreateByUserSchema = new SimpleSchema([
  user_id:
    type: String
    denyUpdate: true
    autoValue: () ->
      return @userId
  ])
