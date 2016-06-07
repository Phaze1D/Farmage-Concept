{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'

require './root.html'

Template.registerHelper 'displayError', () =>
  message = Template.instance().err.get().message if Template.instance().err? and Template.instance().err.get()?
  ret =
    message: message
