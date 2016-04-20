{ Meteor } = require 'meteor/meteor'


Meteor.publish "userData", () ->
  if @userId?
    return Meteor.users.find({_id: @userId},
                             {fields: 'organizations': 1})
  else
    @ready();
