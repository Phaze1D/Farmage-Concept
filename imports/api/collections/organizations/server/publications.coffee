{ Meteor } = require 'meteor/meteor'

Meteor.publish "organizations", () ->
  if @userId?
    organs = Meteor.users.findOne({_id: @userId}).organizations()
    fs = []
    organs.forEach (doc) ->
      fs.push doc.founder().user_id

    return [
      organs,
      Meteor.users.find _id: $in: fs
    ]
  else
    @ready();
