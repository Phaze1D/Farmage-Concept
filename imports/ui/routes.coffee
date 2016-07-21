{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

require 'velocity-animate'
require 'jquery-touch-events'
require 'textarea-autosize'

require './app.coffee'
require './components/components.coffee'
require './models/models.coffee'

loggedIn = (context, redirect) ->
  if Meteor.userId()?
    name = FlowRouter.current().route.name
    if name is 'root' || name is 'login'
      redirect '/home'
  else
    FlowRouter.go 'login'


# Globaly Triggers
FlowRouter.triggers.enter([loggedIn]);


FlowRouter.route '/',
  name: 'root'
  action: () ->
    BlazeLayout.render 'App', main: ''

FlowRouter.route '/login',
  name: 'login'
  action: () ->
    BlazeLayout.render 'App', main: 'Login'


FlowRouter.route '/home',
  name: 'home'
  action: () ->
    BlazeLayout.render 'MainMenu'
