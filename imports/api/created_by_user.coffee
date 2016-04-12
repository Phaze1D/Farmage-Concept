{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

exports.CreateByUserSchema = new SimpleSchema([
  user_id:
    type: String
    index: true
    autoValue: () ->
      return @userId
  ])
