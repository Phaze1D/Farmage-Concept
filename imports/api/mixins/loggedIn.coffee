
module.exports.loggedIn = (methodOptions) ->
  RUN = methodOptions.run

  methodOptions.run = () ->
    unless @userId?
      throw new Meteor.Error 'notLoggedIn', 'Must be logged in'
    RUN.call(@, arguments[0])

  return methodOptions
