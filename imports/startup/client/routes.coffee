{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

require '../../ui/users/login/login.coffee'

FlowRouter.route '/',
  name: 'root'
  action: () ->
    BlazeLayout.render 'Login'
