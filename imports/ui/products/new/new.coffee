{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
ProductModule = require '../../../api/collections/products/products.coffee'
PMethods = require '../../../api/collections/products/methods.coffee'


require './new.html'


Template.ProductsNew.onCreated ->
  @ingredients = new ReactiveVar
  @showInput = new ReactiveVar(false)

  @autorun =>
    @ingredients.set([])

  @insert = (product_doc) =>
    product_doc.organization_id = FlowRouter.getParam('organization_id')
    PMethods.insert.call {product_doc}, (err, res) ->
      console.log err
      params =
        organization_id: product_doc.organization_id
      FlowRouter.go('products.index', params ) unless err?


  @addIngredient = (ingredient_doc) =>
    ingrs = @ingredients.get()
    ingrs.push ingredient_doc
    @ingredients.set(ingrs)

  @removeIngredient = (index) =>
    ings = (ingredient for ingredient, i in @ingredients.get() when i isnt Number index )
    @ingredients.set(ings)



Template.ProductsNew.helpers
  showInput: ->
    Template.instance().showInput.get()

  ingredients: ->
    Template.instance().ingredients.get()

Template.ProductsNew.events
  'click .js-add-ingredient': (event, instance) ->
    instance.showInput.set(true)

  'click .js-cancel-ingredient': (event, instance) ->
    instance.showInput.set(false)

  'click .js-save-ingredient': (event, instance) ->
    instance.showInput.set(false)
    ingredient_doc =
      ingredient_id: instance.$('[name=ingredient_id]').val()
      amount: instance.$('[name=amount]').val()
    instance.addIngredient(ingredient_doc)

  'click .js-remove-ingredient': (event, instance) ->
    index =  instance.$(event.target).closest('.js-ingredient').attr('data-index')
    instance.removeIngredient index

  'submit .js-product-form-new': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-product-form-new')
    product_doc =
      name: $form.find('[name=name]').val()
      measurement: $form.find('[name=measurement]').val()
      description: $form.find('[name=description]').val()
      sku: $form.find('[name=sku]').val()
      unit_price: $form.find('[name=unit_price]').val()
      currency: $form.find('[name=currency]').val()
      tax_rate: $form.find('[name=tax_rate]').val()
      ingredients: instance.ingredients.get()
    instance.insert product_doc
