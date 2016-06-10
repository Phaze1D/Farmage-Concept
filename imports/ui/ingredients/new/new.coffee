{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

IngredientModule = require '../../../api/collections/ingredients/ingredients.coffee'
IMethods = require '../../../api/collections/ingredients/methods.coffee'

require './new.html'


Template.IngredientsNew.onCreated ->

  @insert = (ingredient_doc) =>
    ingredient_doc.organization_id = FlowRouter.getParam('organization_id')
    params =
      organization_id: ingredient_doc.organization_id
    IMethods.insert.call {ingredient_doc}, (err, res) =>
      console.log err
      FlowRouter.go('ingredients.index', params) unless err?



Template.IngredientsNew.helpers



Template.IngredientsNew.events
  'submit .js-ingredient-form-new': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-ingredient-form-new')
    ingredient_doc =
      name: $form.find('[name=name]').val()
      measurement_unit: $form.find('[name=measurement_unit]').val()
    instance.insert ingredient_doc
