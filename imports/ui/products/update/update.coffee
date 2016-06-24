{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'


OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
ProductModule = require '../../../api/collections/products/products.coffee'
IngredientModule = require '../../../api/collections/ingredients/ingredients.coffee'
PMethods = require '../../../api/collections/products/methods.coffee'

require '../../ingredients/selector/selector.coffee'
require './update.html'


Template.ProductsUpdate.onCreated ->
  @product = new ReactiveVar
  @ingredients = new ReactiveVar([])

  @autorun =>
    @product.set ProductModule.Products.findOne FlowRouter.getParam('child_id')
    console.log @product.get().ingredients()

    
  @update = (product_doc) =>
    organization_id = FlowRouter.getParam('organization_id')
    product_id = @product.get()._id

    PMethods.update.call {organization_id, product_id, product_doc}, (err, res) ->
      console.log err
      params =
        organization_id: product_doc.organization_id
      FlowRouter.go('products.index', params ) unless err?



Template.ProductsUpdate.helpers
  product: ->
    Template.instance().product.get()

  ingredients: ->
    Template.instance().ingredients.get()

Template.ProductsUpdate.events

  'submit .js-product-form-update': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-product-form-update')

    product_doc =
      name: $form.find('[name=name]').val()
      measurement: $form.find('[name=measurement]').val()
      description: $form.find('[name=description]').val()
      sku: $form.find('[name=sku]').val()
      unit_price: $form.find('[name=unit_price]').val()
      currency: $form.find('[name=currency]').val()
      tax_rate: $form.find('[name=tax_rate]').val()
    instance.update product_doc
