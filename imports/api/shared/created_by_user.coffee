{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

exports.CreateByUserSchema = new SimpleSchema([
  created_user_id:
    type: String
    index: true
    denyUpdate: true
    optional: true
    autoValue: () ->
      if @isInsert
        return @userId
      else
        @unset()
        return

  updated_user_id:
    type: String
    index: true
    denyInsert: true
    optional: true
    autoValue: () ->
      if @isUpdate
        return @userId
      else
        @unset()
        return

])
