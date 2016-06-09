{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ ReactiveVar } = require 'meteor/reactive-var'


require './signup.html'


Template.Signup.onCreated ->
  @err = new ReactiveVar

  @signup = (email, password, profile) ->
    Accounts.createUser {email, password, profile}, (err) =>
      console.log err
      @err.set err
      FlowRouter.go 'home' unless err?


Template.Signup.events
  'submit .js-signup-form': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-signup-form')
    email = $form.find('[name=email]').val()
    password = $form.find('[name=password]').val()
    profile =
      first_name: $form.find('[name=first_name]').val()
      last_name: $form.find('[name=last_name]').val()

    instance.signup email, password, profile
