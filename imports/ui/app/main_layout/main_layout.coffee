{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'


require './main_layout.html'


Template.MainLayout.onCreated ->
  @ready = new ReactiveVar

  @test = =>
    console.log @

  @subCallback = =>
    callbacks =
      onStop: (err) ->
        console.log err
      onReady: () ->


  @logout = ->
    Meteor.logout (err) ->
      console.log err
      unless err?
        FlowRouter.go 'root'

  @autorun =>
    handler = Meteor.subscribe("organizations", @subCallback)
    @ready.set handler.ready()

Template.MainLayout.onRendered ->
  @autorun =>
    console.log "MR"


Template.MainLayout.helpers
  ready: () ->
    Template.instance().ready.get()




Template.MainLayout.events
  'click .js-logout': (event, instance) ->
    instance.logout()
