{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

require './app.jade'
require './components/PaperDrawerPanel/PaperPanel.coffee'

FlowRouter.route '/',
  name: 'root'
  action: () ->
    BlazeLayout.render 'root'
