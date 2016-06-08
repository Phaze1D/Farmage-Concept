{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'


require './main_menu.html'


Template.MainMenu.onCreated ->
  @ready = new ReactiveVar

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
    handler = Meteor.subscribe("organizations", @subCallback)
    @ready.set handler.ready()

Template.MainMenu.onRendered ->
  @autorun =>
    console.log "MR"


Template.MainMenu.helpers
  ready: () ->
    Template.instance().ready.get()



Template.MainMenu.events
  'click .js-logout': (event, instance) ->
    instance.logout()
