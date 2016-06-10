{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
IngredientModule = require '../../../api/collections/ingredients/ingredients.coffee'

require './index.html'

Template.IngredientsIndex.onCreated ->




Template.IngredientsIndex.helpers
  ingredients: () ->
    IngredientModule.Ingredients.find()

  organization: () ->
    OrganizationModule.Organizations.findOne(_id: FlowRouter.getParam 'organization_id')
