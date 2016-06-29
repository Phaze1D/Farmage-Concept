{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'


OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
ExpenseModule = require '../../../api/collections/expenses/expenses.coffee'
UnitModule = require '../../../api/collections/units/units.coffee'
ProviderModule = require '../../../api/collections/providers/providers.coffee'
EMethods = require '../../../api/collections/expenses/methods.coffee'

require '../../providers/selector/selector.coffee'
require '../../units/selector/selector.coffee'
require './update.html'

Template.ExpensesUpdate.onCreated ->
  @selector = new ReactiveDict
  @unit = new ReactiveVar
  @provider = new ReactiveVar
  @expense = new ReactiveVar
  organ_id = FlowRouter.getParam 'organization_id'
  @unexp_id = FlowRouter.getParam 'child_id'

  @autorun =>
    @expense.set ExpenseModule.Expenses.findOne @unexp_id
    @subscribe 'expense.parents', organ_id, @expense.get()._id
    @unit.set @expense.get().unit().fetch()[0]
    @provider.set @expense.get().provider().fetch()[0]


  @update = (expense_doc) =>
    organization_id = FlowRouter.getParam('organization_id')
    expense_id = @expense.get()._id
    EMethods.update.call {organization_id, expense_id, expense_doc}, (err, res) ->
      console.log err
      params =
        organization_id: organization_id
        child_id: expense_id
      FlowRouter.go('expenses.show', params ) unless err?

  @selectProvider = (provider_id) =>
    @provider.set ProviderModule.Providers.findOne(provider_id)
    @selector.set 'title', null

  @selectUnit = (unit_id) =>
    @unit.set UnitModule.Units.findOne(unit_id)
    @selector.set 'title', null




Template.ExpensesUpdate.helpers
  selector: ->
    instance = Template.instance()
    ret =
      title: instance.selector.get('title')
      select:
        select: instance[instance.selector.get('select')]

  expense: ->
    Template.instance().expense.get()

  provider: ->
    Template.instance().provider.get()

  unit: ->
    Template.instance().unit.get()


Template.ExpensesUpdate.events
  'submit .js-expenses-form-update': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-expenses-form-update')
    expense_doc =
      price: $form.find('[name=price]').val()
      currency: $form.find('[name=currency]').val()
      description: $form.find('[name=description]').val()
      quantity: $form.find('[name=quantity]').val()
      receipt_id: $form.find('[name=receipt_id]').val()
      provider_id: $form.find('[name=provider_id]').val()
      unit_id: $form.find('[name=unit_id]').val()
    instance.update expense_doc

  'focusin .js-input-units': (event, instance) ->
    instance.selector.set 'title', 'UnitsSelector'
    instance.selector.set 'select', 'selectUnit'
    instance.unit.set null

  'focusin .js-input-providers': (event, instance) ->
    instance.selector.set 'title', 'ProvidersSelector'
    instance.selector.set 'select', 'selectProvider'
    instance.provider.set null

  'mousedown .top': (event, instance) ->
    container = instance.$('.js-selector')
    instance.selector.set('title', null) if  !container.is(event.target) &&
                                    container.has(event.target).length is 0 &&
                                    instance.selector.get('title')?
