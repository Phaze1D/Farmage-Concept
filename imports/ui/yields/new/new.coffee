{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
IngredientModule = require '../../../api/collections/ingredients/ingredients.coffee'
UnitModule = require '../../../api/collections/units/units.coffee'
YMethods = require '../../../api/collections/yields/methods.coffee'
EMethods = require '../../../api/collections/events/methods.coffee'

require '../../ingredients/selector/selector.coffee'
require '../../units/selector/selector.coffee'

require './new.html'


Template.YieldsNew.onCreated ->
  @selector = new ReactiveDict
  @ingredient = new ReactiveVar
  @unit = new ReactiveVar

  @insert = (yield_doc) =>
    amount = yield_doc.amount
    delete yield_doc.amount
    yield_doc.organization_id = FlowRouter.getParam('organization_id')
    YMethods.insert.call {yield_doc}, (err, res) =>
      console.log err
      @insertEvent(amount, res, yield_doc.organization_id) if amount > 0 && res?
      params =
        organization_id: yield_doc.organization_id
      FlowRouter.go('yields.index', params ) if amount <= 0 && !err?


  @insertEvent = (amount, yield_id, organization_id) =>
    event_doc =
      amount: amount
      for_type: 'yield'
      for_id: yield_id
      organization_id: organization_id

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      params =
        organization_id: organization_id
      FlowRouter.go('yields.index', params ) unless err?


  @selectIngredient = (ingredient_id) =>
    @ingredient.set(IngredientModule.Ingredients.findOne(ingredient_id))
    @selector.set('title', null)

  @selectUnit = (unit_id) =>
    @unit.set(UnitModule.Units.findOne(unit_id))
    @selector.set('title', null)



Template.YieldsNew.helpers
  selector: ->
    instance = Template.instance()
    ret =
      title: instance.selector.get('title')
      select:
        select: instance[instance.selector.get('select')]

  ingredient: ->
    Template.instance().ingredient.get()

  unit: ->
    Template.instance().unit.get()

Template.YieldsNew.events
  'submit .js-yield-form-new': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-yield-form-new')
    yield_doc =
      name: $form.find('[name=name]').val()
      amount: $form.find('[name=amount]').val()
      ingredient_id: $form.find('[name=ingredient_id]').val()
      unit_id: $form.find('[name=unit_id]').val()
    instance.insert yield_doc

  'focusin .js-input-units': (event, instance) ->
    instance.selector.set 'title', 'UnitsSelector'
    instance.selector.set 'select', 'selectUnit'
    instance.unit.set null

  'focusin .js-input-ingredients': (event, instance) ->
    instance.selector.set 'title','IngredientsSelector'
    instance.selector.set 'select', 'selectIngredient'
    instance.ingredient.set null

  'mousedown .top': (event, instance) ->
    container = instance.$('.js-selector')
    instance.selector.set('title', null) if  !container.is(event.target) &&
                                    container.has(event.target).length is 0 &&
                                    instance.selector.get('title')?
