{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
UnitModule = require '../../../api/collections/units/units.coffee'
UMethods = require '../../../api/collections/units/methods.coffee'
EMethods = require '../../../api/collections/events/methods.coffee'

require './new.html'

Template.UnitsNew.onCreated ->

  @insert = (unit_doc) =>
    amount = unit_doc.amount
    unit_doc.amount = 0
    unit_doc.organization_id = FlowRouter.getParam('organization_id')

    UMethods.insert.call {unit_doc}, (err, res) =>
      console.log err
      @insertEvent(amount, res, unit_doc.organization_id) if amount > 0 && res?
      
      params =
        organization_id: unit_doc.organization_id
      FlowRouter.go('units.index', params ) if amount <= 0 && !err?

  @insertEvent = (amount, unit_id, organization_id) =>
    event_doc =
      amount: amount
      description: 'inital'
      for_type: 'unit'
      for_id: unit_id
      organization_id: organization_id

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      params =
        organization_id: organization_id
      FlowRouter.go('units.index', params ) unless err?


Template.UnitsNew.helpers
  parent_id: ->
    FlowRouter.getParam('parent_id')

Template.UnitsNew.events
  'submit .js-unit-new': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-unit-new')
    unit_doc =
      name: $form.find('[name=name]').val()
      description: $form.find('[name=description]').val()
      amount: $form.find('[name=amount]').val()
      unit_id: $form.find('[name=unit_id]').val()

    instance.insert unit_doc
