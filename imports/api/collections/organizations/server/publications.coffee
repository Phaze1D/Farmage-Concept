{ Meteor } = require 'meteor/meteor'

Meteor.publish "organizations", () ->
  if @userId?
    return Meteor.users.findOne({_id: @userId}).organizations()
  else
    @ready();
