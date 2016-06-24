{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'


OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
UnitModule = require '../../../api/collections/units/units.coffee'
UMethods = require '../../../api/collections/units/methods.coffee'
EMethods = require '../../../api/collections/events/methods.coffee'

require '../selector/selector.coffee'
require './update.html'

Template.UnitsUpdate.onCreated ->
  @parent = new ReactiveVar
  @unit = new ReactiveVar
  @change = new ReactiveVar(false)
  @amounts = new ReactiveDict(eamount: '0')
  @selector = new ReactiveDict

  @autorun =>
    unit = UnitModule.Units.findOne FlowRouter.getParam 'child_id'
    @unit.set(unit)
    if unit?
      @amounts.set('uamount', unit.amount)
      @subscribe 'unit.parent', unit.organization_id, unit._id
      @parent.set unit.unit().fetch()[0]

  @update = (unit_doc) =>
    organization_id = FlowRouter.getParam 'organization_id'
    unit_id = FlowRouter.getParam 'child_id'

    UMethods.update.call {organization_id, unit_id, unit_doc}, (err, res) =>
      console.log err
      params =
        organization_id: organization_id
        child_id: unit_id
      FlowRouter.go('units.show', params ) unless err?

  @applyEvent = (event_doc) =>
    event_doc.for_type = 'unit'
    event_doc.for_id = @unit.get()._id
    event_doc.organization_id = FlowRouter.getParam 'organization_id'

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      @change.set(false) unless err?


  @selectParent = (unit_id) =>
    @parent.set UnitModule.Units.findOne unit_id
    @selector.set('title', null)



Template.UnitsUpdate.helpers
  selector: ->
    instance = Template.instance()
    ret =
      title: instance.selector.get('title')
      select:
        select: instance[instance.selector.get('select')]

  unit: ->
    Template.instance().unit.get()

  parent: ->
    Template.instance().parent.get()

  amounts: ->
    Template.instance().amounts.all()

  change: ->
    Template.instance().change.get()


Template.UnitsUpdate.events
  'submit .js-unit-update': (event, instance) ->
    event.preventDefault()
    $form = instance.$('.js-unit-update')
    unit_doc =
      name: $form.find('[name=name]').val()
      description: $form.find('[name=description]').val()
      unit_id: $form.find('[name=unit_id]').val()

    instance.update unit_doc

  'focusin .js-input-parent': (event, instance) ->
    instance.selector.set 'title', 'UnitsSelector'
    instance.selector.set 'select', 'selectParent'
    instance.parent.set null

  'click .js-change-button': (event, instance) ->
    instance.change.set true

  'click .js-cancel-event': (event, instance) ->
    instance.amounts.set('uamount', instance.unit.get().amount)
    instance.amounts.set('eamount', 0)
    instance.change.set false

  'change .js-eamount-input': (event, instance) ->
    value = Number instance.$(event.target).val()
    uamount = instance.unit.get().amount + value
    instance.amounts.set('uamount', uamount)
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
