{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

require 'velocity-animate'


require './app.jade'
require './components/PaperDrawerPanel/PaperDrawerPanel.coffee'
require './components/PaperHeaderPanel/PaperHeaderPanel.coffee'
require './components/PaperRipple/PaperRipple.coffee'
require './components/PaperItem/PaperItem.coffee'
require './components/PaperMenu/PaperMenu.coffee'
require './components/PaperCard/PaperCard.coffee'

FlowRouter.route '/',
  name: 'root'
  action: () ->
    BlazeLayout.render 'root'
