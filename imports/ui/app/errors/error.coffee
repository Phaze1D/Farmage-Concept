{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

require './error.html'

Template.ErrorT.onCreated ->
  @autorun =>
    new SimpleSchema(
      message:
        type: String
        optional: true
    ).validate @data
