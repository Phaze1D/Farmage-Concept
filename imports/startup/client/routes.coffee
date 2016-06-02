{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

require '../../ui/app/root/root.html'

require '../../ui/app/main_layout/main_layout.coffee'

require '../../ui/users/login/login.coffee'
require '../../ui/users/update/update.coffee'

require '../../ui/organizations/new/new.coffee'

loggedIn = () ->
  if Meteor.userId()?
    FlowRouter.go 'home'
  else
    FlowRouter.go 'root'



FlowRouter.route '/',
  name: 'root'
  triggersEnter: [loggedIn]
  action: () ->
    BlazeLayout.render 'Root'


FlowRouter.route '/home',
  name: 'home'
  triggersEnter: [loggedIn]
  action: () ->
    BlazeLayout.render 'MainLayout'



# Users Group
users = FlowRouter.group
  prefix: '/user'
  name: 'users'

users.route '/update',
  name: 'update'
  action: () ->
    BlazeLayout.render 'UserUpdate'



# Organization Group
organizations = FlowRouter.group
  prefix: '/organizations'
  name: 'organizations'

organizations.route '/new',
  name: 'organizations.new'
  action: () ->
    BlazeLayout.render 'OrganizationsNew'
