{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

exports.BelongsOrganizationSchema =
  new SimpleSchema([
    organization_id:
      type: String
      index: true
      denyUpdate: true
      autoValue: () ->
        if @userId?
          return Meteor.users.findOne(@userId).organization_id # Wrong
        else
          throw new Meteor.Error 'notLoggedIn', 'Must be logged in'


  ])
