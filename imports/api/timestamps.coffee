

share.TimestampSchema = new SimpleSchema(
  created_at:
    type: Date
    label: TAPi18n.__ "created_at"
    autoValue: () ->
      if this.isInsert
        return new Date();
      else if this.isUpsert
        return $setOnInsert: new Date()
      else
        this.unset()
        return
    optional: true
    denyUpdate: true

  updated_at:
    type: Date
    label: TAPi18n.__ "updated_at"
    autoValue: () ->
      if this.isUpdate
        return new Date()
    denyInsert: true
    optional: true
)
