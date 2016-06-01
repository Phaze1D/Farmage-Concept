{ Meteor } = require 'meteor/meteor'

require './login.html'


Template.Login.onCreated ->




Template.Login.events
  'submit .login-form': (event, instance) ->
    event.preventDefault()
    console.log $(event.target).find('[name=email]').val()
