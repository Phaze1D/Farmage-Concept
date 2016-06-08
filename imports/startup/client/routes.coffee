{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

require '../../ui/app/root/root.coffee'
require '../../ui/app/layouts/main_menu.coffee'
require '../../ui/app/layouts/organization_menu.coffee'
require '../../ui/app/errors/error.coffee'

require '../../ui/users/login/login.coffee'
require '../../ui/users/update/update.coffee'

require '../../ui/organizations/new/new.coffee'
require '../../ui/organizations/index/index.coffee'

require '../../ui/contact_info/addresses.coffee'
require '../../ui/contact_info/telephones.coffee'


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
    BlazeLayout.render 'MainMenu'



# Users Group
users = FlowRouter.group
  prefix: '/user'
  name: 'users'

users.route '/update',
  name: 'user.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: "UserUpdate"



# Organization Group
organizations = FlowRouter.group
  prefix: '/organizations'
  name: 'organizations'

organizations.route '/',
  name: 'organizations.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: "OrganizationsIndex"

organizations.route '/new',
  name: 'organizations.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: "OrganizationsNew"

organizations.route '/:organization_id',
  name: 'organization.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: "OrganizationMenu"

organizations.route '/:organization_id/update',
  name: 'organization.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: "OrganizationMenu"


# Customer Group
customers = organizations.group
  prefix: '/:organization_id/customers'
  name: 'customers'

customers.route '/',
  name: 'customers'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

customers.route '/index',
  name: 'customers.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

customers.route '/new',
  name: 'customers.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

customers.route '/show',
  name: 'customers.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

customers.route '/update',
  name: 'customers.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'


# Events Group
events = organizations.group
  prefix: '/:organization_id/events'
  name: 'events'

events.route '/',
  name: 'events'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

events.route '/index',
  name: 'events.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

events.route '/show',
  name: 'events.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'


# Expenses Group
expenses = organizations.group
  prefix: '/:organization_id/expenses'
  name: 'expenses'

expenses.route '/',
  name: 'expenses'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

expenses.route '/index',
  name: 'expenses.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

expenses.route '/new',
  name: 'expenses.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

expenses.route '/show',
  name: 'expenses.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

expenses.route '/update',
  name: 'expenses.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'


# Ingredints Group
ingredients = organizations.group
  prefix: '/:organization_id/ingredients'
  name: 'ingredients'

ingredients.route '/',
  name: 'ingredients'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

ingredients.route '/index',
  name: 'ingredients.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

ingredients.route '/new',
  name: 'ingredients.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

ingredients.route '/show',
  name: 'ingredients.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

ingredients.route '/update',
  name: 'ingredients.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'


# Inventories Group
inventories = organizations.group
  prefix: '/:organization_id/inventories'
  name: 'inventories'

inventories.route '/',
  name: 'inventories'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

inventories.route '/index',
  name: 'inventories.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

inventories.route '/new',
  name: 'inventories.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

inventories.route '/show',
  name: 'inventories.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

inventories.route '/update',
  name: 'inventories.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'


# Products Group
products = organizations.group
  prefix: '/:organization_id/products'
  name: 'products'

products.route '/',
  name: 'products'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

products.route '/index',
  name: 'products.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

products.route '/new',
  name: 'products.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

products.route '/show',
  name: 'products.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

products.route '/update',
  name: 'products.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'


# Providers Group
providers = organizations.group
  prefix: '/:organization_id/providers'
  name: 'providers'

providers.route '/',
  name: 'providers'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

providers.route '/index',
  name: 'providers.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

providers.route '/new',
  name: 'providers.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

providers.route '/show',
  name: 'providers.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

providers.route '/update',
  name: 'providers.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'



# Receipts Group
receipts = organizations.group
  prefix: '/:organization_id/receipts'
  name: 'receipts'

receipts.route '/',
  name: 'receipts'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

receipts.route '/index',
  name: 'receipts.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

receipts.route '/new',
  name: 'receipts.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

receipts.route '/show',
  name: 'receipts.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

receipts.route '/update',
  name: 'receipts.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'


# Sells Group
sells = organizations.group
  prefix: '/:organization_id/sells'
  name: 'sells'

sells.route '/',
  name: 'sells'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

sells.route '/index',
  name: 'sells.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

sells.route '/new',
  name: 'sells.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

sells.route '/show',
  name: 'sells.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

sells.route '/update',
  name: 'sells.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'


# Units Group
units = organizations.group
  prefix: '/:organization_id/units'
  name: 'units'

units.route '/',
  name: 'units'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

units.route '/index',
  name: 'units.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

units.route '/new',
  name: 'units.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

units.route '/show',
  name: 'units.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

units.route '/update',
  name: 'units.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'



# OUsers Group
ousers = organizations.group
  prefix: '/:organization_id/ousers'
  name: 'ousers'

ousers.route '/',
  name: 'ousers'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

ousers.route '/index',
  name: 'ousers.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

ousers.route '/new',
  name: 'ousers.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

ousers.route '/show',
  name: 'ousers.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'


# Yields Group
yields = organizations.group
  prefix: '/:organization_id/yields'
  name: 'yields'

yields.route '/',
  name: 'yields'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

yields.route '/index',
  name: 'yields.index'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

yields.route '/new',
  name: 'yields.new'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

yields.route '/show',
  name: 'yields.show'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'

yields.route '/update',
  name: 'yields.update'
  action: () ->
    BlazeLayout.render 'MainMenu', main: 'OrganizationMenu'
