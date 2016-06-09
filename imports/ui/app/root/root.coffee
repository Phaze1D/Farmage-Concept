{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'


require './root.html'
require '../../users/login/login.coffee'
require '../../users/signup/signup.coffee'


Template.registerHelper 'displayError', () =>
  message = Template.instance().err.get().message if Template.instance().err? and Template.instance().err.get()?
  ret =
    message: message


Template.Root.onCreated ->
  @login = new ReactiveVar(true)

Template.Root.helpers
  login: () ->
    Template.instance().login.get()

Template.Root.events
  'click .js-show-signup': (event, instance) ->
    instance.login.set(false)

  'click .js-show-login': (event, instance) ->
    instance.login.set(true)
