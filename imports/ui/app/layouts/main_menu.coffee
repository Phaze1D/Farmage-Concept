{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'


{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'


require './main_menu.html'


Template.MainMenu.onCreated ->
  @user = new ReactiveVar

  @subCallback =
    onStop: (err) ->
      console.log "sub stop #{err}"
    onReady: () ->


  @logout = ->
    Meteor.logout( (err) ->
      console.log err
      FlowRouter.go 'root' unless err?
    )

  @autorun =>
    @subscribe("organizations", @subCallback)

Template.MainMenu.onRendered ->
  @autorun =>
    console.log "MR"


Template.MainMenu.helpers
  user: ->
    Meteor.users.findOne()

  email: ->
    Meteor.users.findOne().emails[0].address

Template.MainMenu.events
  'click .js-logout': (event, instance) ->
    instance.logout()
