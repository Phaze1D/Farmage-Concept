{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'



require './main_layout.html'


Template.MainLayout.onCreated ->
  @logout = ->
    Meteor.logout (err) ->
      console.log err



Template.MainLayout.events
  'click .js-logout': (event, instance) ->
    instance.logout()
