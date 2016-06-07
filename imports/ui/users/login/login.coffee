{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ ReactiveVar } = require 'meteor/reactive-var'




require './login.html'


Template.Login.onCreated ->
  @err = new ReactiveVar

  @login = (email, password) ->
    Meteor.loginWithPassword email, password, (err) =>
      console.log err
      @err.set err
      unless err?
        Meteor.logoutOtherClients( (er) =>
          @err.set err
          FlowRouter.go 'home' unless er?
        )


  @signup = (email, password) ->
    Accounts.createUser {email, password}, (err) =>
      console.log err
      @err.set err
      FlowRouter.go 'home' unless err?




Template.Login.events
  'click .js-login-b': (event, instance) ->
    $form = instance.$('.js-login-form')
    email = $form.find('[name=email]').val()
    password = $form.find('[name=password]').val()
    instance.login email, password

  'click .js-signup-b': (event, instance) ->
    $form = instance.$('.js-login-form')
    email = $form.find('[name=email]').val()
    password = $form.find('[name=password]').val()
    instance.signup email, password
