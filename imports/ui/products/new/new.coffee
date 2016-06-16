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
require './new.html'


Template.ProductsNew.onCreated ->
  @selector = new ReactiveDict
  @ingredients = new ReactiveVar([])

  @insert = (product_doc) =>
    product_doc.organization_id = FlowRouter.getParam('organization_id')
    PMethods.insert.call {product_doc}, (err, res) ->
      console.log err
      params =
        organization_id: product_doc.organization_id
      FlowRouter.go('products.index', params ) unless err?


  @removeIngredient = (index) =>
    ings = (ingredient for ingredient, i in @ingredients.get() when i isnt Number index )
    @ingredients.set(ings)

  @selectIngredient = (ingredient_id) =>
    @selector.set('title', null)
    return for ingredient in @ingredients.get() when ingredient._id is ingredient_id
    ings = @ingredients.get()
    ings.push IngredientModule.Ingredients.findOne ingredient_id
    @ingredients.set ings


Template.ProductsNew.helpers
  selector: ->
    instance = Template.instance()
    ret =
      title: instance.selector.get('title')
      select:
        select: instance[instance.selector.get('select')]

  ingredients: ->
    Template.instance().ingredients.get()

Template.ProductsNew.events
  'click .js-add-ingredient': (event, instance) ->
    instance.selector.set 'title', 'IngredientsSelector'
    instance.selector.set 'select', 'selectIngredient'

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

  'mousedown .top': (event, instance) ->
    container = instance.$('.js-selector')
    instance.selector.set('title', null) if  !container.is(event.target) &&
                                    container.has(event.target).length is 0 &&
                                    instance.selector.get('title')?
