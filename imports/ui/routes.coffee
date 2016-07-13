{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

require 'velocity-animate'


require './app.jade'
require './components/PaperDrawerPanel/PaperDrawerPanel.coffee'

FlowRouter.route '/',
  name: 'root'
  action: () ->
    BlazeLayout.render 'root'
