{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

require 'velocity-animate'
require 'jquery-touch-events'
require 'textarea-autosize'

require './app.coffee'
require './components/components.coffee'
require './models/models.coffee'
require './layouts/structure.coffee'

loggedIn = (context, redirect) ->
  if Meteor.userId()?
    name = FlowRouter.current().route.name
    if name is 'root' || name is 'login'
      redirect '/structure'
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
    BlazeLayout.render 'App', main: 'login'


FlowRouter.route '/home',
  name: 'home'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'



# Users Group
users = FlowRouter.group
  prefix: '/user'
  name: 'users'

users.route '/show',
  name: 'user.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'



# Organization Group
organizations = FlowRouter.group
  prefix: '/organizations'
  name: 'organizations'

organizations.route '/',
  name: 'organizations.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

organizations.route '/new',
  name: 'organizations.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

organizations.route '/:organization_id',
  name: 'organization.show'
  action: () ->
    BlazeLayout.render 'App', main: "structure"

organizations.route '/:organization_id/update',
  name: 'organization.update'
  action: () ->
    BlazeLayout.render 'App', main: "structure"


# Customer Group
customers = organizations.group
  prefix: '/:organization_id/customers'
  name: 'customers'

customers.route '/',
  name: 'customers'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

customers.route '/index',
  name: 'customers.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

customers.route '/new',
  name: 'customers.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

customers.route '/:child_id/show',
  name: 'customers.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

customers.route '/:child_id/update',
  name: 'customers.update'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'


# Events Group
events = organizations.group
  prefix: '/:organization_id/events'
  name: 'events'

events.route '/',
  name: 'events'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

events.route '/index',
  name: 'events.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

events.route '/:child_id/show',
  name: 'events.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'


# Expenses Group
expenses = organizations.group
  prefix: '/:organization_id/expenses'
  name: 'expenses'

expenses.route '/',
  name: 'expenses'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

expenses.route '/index',
  name: 'expenses.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

expenses.route '/new',
  name: 'expenses.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

expenses.route '/:child_id/show',
  name: 'expenses.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

expenses.route '/:child_id/update',
  name: 'expenses.update'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'


# Ingredints Group
ingredients = organizations.group
  prefix: '/:organization_id/ingredients'
  name: 'ingredients'

ingredients.route '/',
  name: 'ingredients'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

ingredients.route '/index',
  name: 'ingredients.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

ingredients.route '/new',
  name: 'ingredients.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

ingredients.route '/:child_id/show',
  name: 'ingredients.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

ingredients.route '/:child_id/update',
  name: 'ingredients.update'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'


# Inventories Group
inventories = organizations.group
  prefix: '/:organization_id/inventories'
  name: 'inventories'

inventories.route '/',
  name: 'inventories'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

inventories.route '/index',
  name: 'inventories.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

inventories.route '/new',
  name: 'inventories.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

inventories.route '/:child_id/show',
  name: 'inventories.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

inventories.route '/:child_id/update',
  name: 'inventories.update'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'


# Products Group
products = organizations.group
  prefix: '/:organization_id/products'
  name: 'products'

products.route '/',
  name: 'products'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

products.route '/index',
  name: 'products.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

products.route '/new',
  name: 'products.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

products.route '/:child_id/show',
  name: 'products.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

products.route '/:child_id/update',
  name: 'products.update'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'


# Providers Group
providers = organizations.group
  prefix: '/:organization_id/providers'
  name: 'providers'

providers.route '/',
  name: 'providers'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

providers.route '/index',
  name: 'providers.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

providers.route '/new',
  name: 'providers.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

providers.route '/:child_id/show',
  name: 'providers.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

providers.route '/:child_id/update',
  name: 'providers.update'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'


# Sells Group
sells = organizations.group
  prefix: '/:organization_id/sells'
  name: 'sells'

sells.route '/',
  name: 'sells'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

sells.route '/index',
  name: 'sells.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

sells.route '/new',
  name: 'sells.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

sells.route '/:child_id/show',
  name: 'sells.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

sells.route '/:child_id/update',
  name: 'sells.update'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

sells.route '/:child_id/pay',
  name: 'sells.update.pay'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'


# Units Group
units = organizations.group
  prefix: '/:organization_id/units'
  name: 'units'

units.route '/',
  name: 'units'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

units.route '/index',
  name: 'units.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

units.route '/new',
  name: 'units.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

units.route '/:child_id/show',
  name: 'units.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

units.route '/:child_id/update',
  name: 'units.update'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'



# OUsers Group
ousers = organizations.group
  prefix: '/:organization_id/ousers'
  name: 'ousers'

ousers.route '/',
  name: 'ousers'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

ousers.route '/index',
  name: 'ousers.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

ousers.route '/new',
  name: 'ousers.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

ousers.route '/:child_id/show',
  name: 'ousers.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

ousers.route '/:child_id/update',
  name: 'ousers.update'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'


# Yields Group
yields = organizations.group
  prefix: '/:organization_id/yields'
  name: 'yields'

yields.route '/',
  name: 'yields'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

yields.route '/index',
  name: 'yields.index'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

yields.route '/new',
  name: 'yields.new'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

yields.route '/:child_id/show',
  name: 'yields.show'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'

yields.route '/:child_id/update',
  name: 'yields.update'
  action: () ->
    BlazeLayout.render 'App', main: 'structure'
