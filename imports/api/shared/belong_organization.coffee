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
          organizations = Meteor.users.findOne(@userId).organizations
          for organization in organizations
            if organization.selected
              return organization.organization_id
          throw new Meteor.Error '500', 'No organization is selected'
        else
          throw new Meteor.Error 'notLoggedIn', 'Must be logged in'
  ])
