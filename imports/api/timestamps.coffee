
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ TAPi18n } = require 'meteor/tap:i18n'

exports.TimestampSchema = new SimpleSchema(
  created_at:
    type: Date
    label: TAPi18n.__ "created_at"
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

  updated_at:
    type: Date
    label: TAPi18n.__ "updated_at"
    autoValue: () ->
      if @isUpdate
        return new Date()
    denyInsert: true
    optional: true
)
