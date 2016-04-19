
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

exports.TimestampSchema = new SimpleSchema(
  createdAt:
    type: Date
    label: "created_at"
    autoValue: () ->
      if @isInsert
        return new Date();
      else if @isUpsert
        return $setOnInsert: new Date()
      else
        @unset()
        return
    optional: true
    denyUpdate: true

  updatedAt:
    type: Date
    label: "updated_at"
    autoValue: () ->
      if @isUpdate
        return new Date()
    denyInsert: true
    optional: true
)
