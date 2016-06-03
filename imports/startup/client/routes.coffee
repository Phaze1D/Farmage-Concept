{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

require '../../ui/app/root/root.html'
require '../../ui/app/main_layout/main_layout.coffee'

require '../../ui/users/login/login.coffee'
require '../../ui/users/update/update.coffee'

require '../../ui/organizations/new/new.coffee'
require '../../ui/organizations/index/index.coffee'
require '../../ui/organizations/show/show.coffee'




loggedIn = () ->
  if Meteor.userId()?
    FlowRouter.go 'home' if FlowRouter.current().route.name is 'root'
  else
    FlowRouter.go 'root'

# Globaly Triggers
FlowRouter.triggers.enter([loggedIn]);


FlowRouter.route '/',
  name: 'root'
  action: () ->
    BlazeLayout.render 'Root'


FlowRouter.route '/home',
  name: 'home'
  action: () ->
    BlazeLayout.render 'MainLayout'



# Users Group
users = FlowRouter.group
  prefix: '/user'
  name: 'users'

users.route '/update',
  name: 'user.update'
  action: () ->
    BlazeLayout.render 'MainLayout', main: "UserUpdate"



# Organization Group
organizations = FlowRouter.group
  prefix: '/organizations'
  name: 'organizations'

organizations.route '/',
  name: 'organizations.index'
  action: () ->
    BlazeLayout.render 'MainLayout', main: "OrganizationsIndex"

organizations.route '/new',
  name: 'organizations.new'
  action: () ->
    BlazeLayout.render 'MainLayout', main: "OrganizationsNew"

organizations.route '/:id',
  name: 'organization.show'
  action: () ->
    BlazeLayout.render 'MainLayout', main: "OrganizationShow"
