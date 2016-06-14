{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
YMethods = require '../../../api/collections/yields/methods.coffee'
EMethods = require '../../../api/collections/events/methods.coffee'


require './new.html'


Template.YieldsNew.onCreated ->

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


Template.YieldsNew.helpers


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
