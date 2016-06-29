{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
IngredientModule = require '../../../api/collections/ingredients/ingredients.coffee'
YieldModule = require '../../../api/collections/yields/yields.coffee'
UnitModule = require '../../../api/collections/units/units.coffee'
YMethods = require '../../../api/collections/yields/methods.coffee'
EMethods = require '../../../api/collections/events/methods.coffee'

require '../../ingredients/selector/selector.coffee'
require '../../units/selector/selector.coffee'

require './update.html'


Template.YieldsUpdate.onCreated ->
  @selector = new ReactiveDict
  @yield = new ReactiveVar
  @change = new ReactiveVar(false)
  @amounts = new ReactiveDict(eamount: '0')
  @ingredient = new ReactiveVar
  @unit = new ReactiveVar
  unyi_id = FlowRouter.getParam 'child_id'

  @autorun =>
    _yield = YieldModule.Yields.findOne unyi_id
    @yield.set _yield
    @subscribe 'yield.parents', _yield.organization_id, _yield._id
    @amounts.set('yamount', _yield.amount)
    @unit.set _yield.unit().fetch()[0]
    @ingredient.set _yield.ingredient().fetch()[0]

  @update = (yield_doc) =>
    organization_id = FlowRouter.getParam 'organization_id'
    yield_id = FlowRouter.getParam 'child_id'

    YMethods.update.call {organization_id, yield_id, yield_doc}, (err, res) =>
      params =
        organization_id: organization_id
        child_id: yield_id
      FlowRouter.go 'yields.show', params unless err?

  @selectUnit = (unit_id) =>
    @unit.set(UnitModule.Units.findOne(unit_id))
    @selector.set('title', null)


  @applyEvent = (event_doc) =>
    event_doc.for_type = 'yield'
    event_doc.for_id = @yield.get()._id
    event_doc.organization_id = FlowRouter.getParam 'organization_id'

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      @change.set(false) unless err?



Template.YieldsUpdate.helpers
  selector: ->
    instance = Template.instance()
    ret =
      title: instance.selector.get('title')
      select:
        select: instance[instance.selector.get('select')]

  yield: ->
    Template.instance().yield.get()

  change: ->
    Template.instance().change.get()

  amounts: ->
    Template.instance().amounts.all()

  ingredient: ->
    Template.instance().ingredient.get()

  unit: ->
    Template.instance().unit.get()


Template.YieldsUpdate.events
  'submit .js-yield-form-update': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-yield-form-update')
    yield_doc =
      name: $form.find('[name=name]').val()
      unit_id: $form.find('[name=unit_id]').val()
    instance.update yield_doc

  'focusin .js-input-units': (event, instance) ->
    instance.selector.set 'title', 'UnitsSelector'
    instance.selector.set 'select', 'selectUnit'
    instance.unit.set null

  'click .js-change-button': (event, instance) ->
    instance.change.set true

  'click .js-cancel-event': (event, instance) ->
    instance.amounts.set('uamount', instance.yield.get().amount)
    instance.amounts.set('eamount', 0)
    instance.change.set false

  'change .js-eamount-input': (event, instance) ->
    value = Number instance.$(event.target).val()
    yamount = instance.yield.get().amount + value
    instance.amounts.set('yamount', yamount)
    instance.amounts.set('eamount', value)

  'click .js-apply-event': (event, instance) ->
    value = Number instance.$('.js-eamount-input').val()
    $form = instance.$('.js-unit-update')
    if value isnt 0 && instance.change.get()
      event_doc =
        amount: value
        description: $form.find('[name=event_description]').val()

      instance.applyEvent event_doc

  'mousedown .top': (event, instance) ->
    container = instance.$('.js-selector')
    instance.selector.set('title', null) if  !container.is(event.target) &&
                                    container.has(event.target).length is 0 &&
                                    instance.selector.get('title')?
