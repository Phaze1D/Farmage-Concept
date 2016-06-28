{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'
Big = require 'big.js'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
InventoryModule = require '../../../api/collections/inventories/inventories.coffee'
ProductModule = require '../../../api/collections/products/products.coffee'
YieldModule = require '../../../api/collections/yields/yields.coffee'

IMethods = require '../../../api/collections/inventories/methods.coffee'
EMethods = require '../../../api/collections/events/methods.coffee'

require '../../products/selector/selector.coffee'
require '../../yields/selector/selector.coffee'
require './update.html'


Template.InventoriesUpdate.onCreated ->
  @selector = new ReactiveDict
  @inventory = new ReactiveVar
  @ingyields = new ReactiveDict
  @product = new ReactiveVar
  @amounts = new ReactiveDict
  @event = new ReactiveVar
  @change = new ReactiveDict


  @autorun =>
    inventory = InventoryModule.Inventories.findOne FlowRouter.getParam 'child_id'
    if inventory?
      @inventory.set inventory
      @subscribe 'inventory.parents', inventory.organization_id, inventory._id
      @product.set inventory.product().fetch()[0]

      @amounts.set 'inamount', inventory.amount
      @amounts.set 'chamount', 0
      if @subscriptionsReady()
        for yield_item in inventory.yield_objects
          _yield = YieldModule.Yields.findOne yield_item.yield_id
          ying = camount: 0, yields: {}
          ying.yields[_yield._id] =
            yield: _yield
            amount_taken: yield_item.amount_taken
            min: yield_item.amount_taken
          @ingyields.set(_yield.ingredient_id, ying)


  @selectYield = (yield_id) =>
    _yield = YieldModule.Yields.findOne(yield_id)

    for ping in @product.get().pingredients
      if ping.ingredient_id is _yield.ingredient_id
        ying = @ingyields.get(_yield.ingredient_id)
        ying = camount: 0, yields: {} unless ying?
        unless ying.yields[yield_id]?
          ying.yields[yield_id] =
            yield: _yield
            amount_taken: 0
            min: 0
          @ingyields.set(_yield.ingredient_id, ying)
          @checkCAmount(_yield.ingredient_id)
    @selector.set('title', null)



  @checkCAmount = (ingredient_id) =>
    sum = 0
    for key, value of @ingyields.get(ingredient_id).yields
      sum += value.amount_taken

    for ping in @product.get().pingredients
      if ping.ingredient_id is ingredient_id
        camount = new Big(sum).div(ping.amount)
        ying = @ingyields.get(ingredient_id)
        ying.camount = Number camount
        @ingyields.set(ingredient_id, ying)

    min = null
    for key, value of @ingyields.all()
      if !min? || min.camount > value.camount
        min = value
    @invAmount.set(min.camount) if min?

  @insert = (inventory_doc) =>
    yield_objects = inventory_doc.yield_objects
    amount = inventory_doc.amount
    delete inventory_doc.amount
    delete inventory_doc.yield_objects
    inventory_doc.organization_id = FlowRouter.getParam('organization_id')

    IMethods.insert.call {inventory_doc}, (err, res) =>
      console.log err
      if res?
        console.log @event.get()
        if yield_objects.length > 0
          @packEvent(amount, yield_objects, res, inventory_doc.organization_id)
        else if @event.get()? && @event.get().amount >
          @userEvent(res)
        else
          params =
            organization_id: inventory_doc.organization_id
          FlowRouter.go('inventories.index', params ) unless err?

  @packEvent = (amount, yield_objects, inventory_id, organization_id) =>
    EMethods.pack.call {organization_id, inventory_id, yield_objects, amount}, (err, res) =>
      console.log err
      @delete(organization_id, inventory_id) if err?
      params =
        organization_id: organization_id
      FlowRouter.go('inventories.index', params ) unless err?

  @userEvent = (inventory_id) =>
    event_doc = @event.get()
    event_doc.for_type = 'inventory'
    event_doc.for_id = inventory_id
    event_doc.organization_id = FlowRouter.getParam 'organization_id'

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      @delete(organization_id, inventory_id) if err?
      params =
        organization_id: event_doc.organization_id
      FlowRouter.go('inventories.index', params ) unless err?

  @delete = (organization_id, inventory_id) =>
    IMethods.delete.call {organization_id, inventory_id}, (err, res) =>
      console.log err


Template.InventoriesUpdate.helpers
  selector: ->
    instance = Template.instance()
    ret =
      title: instance.selector.get('title')
      select:
        select: instance[instance.selector.get('select')]

  inventory: ->
    Template.instance().inventory.get()

  yields: (ingredient_id) ->
    ying = Template.instance().ingyields.get(ingredient_id)
    (value for key, value of ying.yields) if ying?

  packing: ->
    Template.instance().change.get('packing') &&
    Template.instance().product.get()?

  manually: ->
    Template.instance().change.get('manually') &&
    Template.instance().product.get()?

  product: ->
    Template.instance().product.get()

  amounts: ->
    Template.instance().amounts.all()

  camount: (ingredient_id) ->
    ying = Template.instance().ingyields.get(ingredient_id)
    if ying?
      ying.camount
    else
      0


Template.InventoriesUpdate.events

  'click .js-yield-remove': (event, instance) ->
    ingredient_id = instance.$(event.target).closest('.js-ingredient').attr('data-id')
    yield_id = instance.$(event.target).closest('.js-yield').attr('data-id')
    ying = instance.ingyields.get(ingredient_id)
    delete ying.yields[yield_id]
    instance.ingyields.set(ingredient_id, ying)
    instance.checkCAmount ingredient_id

  'click .js-yield-add': (event, instance) ->
    instance.selector.set 'title', 'YieldsSelector'
    instance.selector.set 'select', 'selectYield'

  'change .js-at-input': (event, instance) ->
    ingredient_id = instance.$(event.target).closest('.js-ingredient').attr('data-id')
    yield_id = instance.$(event.target).closest('.js-yield').attr('data-id')
    ying = instance.ingyields.get(ingredient_id)
    value = Number instance.$(event.target).val()
    if value > 0
      ying.yields[yield_id].amount_taken = value
    else
      delete ying.yields[yield_id]
    instance.ingyields.set(ingredient_id, ying)
    instance.checkCAmount ingredient_id

  'click .js-changeM-b': (event, instance) ->
    instance.change.set('packing', false)
    instance.change.set('manually', true) if instance.product.get()?
    instance.event.set null
    instance.ingyields.clear()
    instance.invAmount.set 0

  'click .js-changeP-b': (event, instance) ->
    instance.change.set('manually', false)
    instance.event.set null
    instance.invAmount.set 0
    instance.change.set('packing', true)

  'change .js-mamount-input': (event, instance) ->
    value = Number instance.$(event.target).val()
    if value < 0
      instance.$(event.target).val(0)
      value = 0

    instance.invAmount.set value

  'click .js-apply-event': (event, instance) ->
    value = Number instance.invAmount.get()
    $form = instance.$('.js-inventories-form-update')
    instance.change.set 'manually', false
    if value isnt 0
      event_doc =
        amount: value
        description: $form.find('[name=event_description]').val()
      instance.event.set event_doc


  'click .js-cancel-event': (event, instance) ->
    instance.invAmount.set 0
    instance.event.set null
    instance.change.set 'manually', false



  'submit .js-inventories-form-update': (event, instance) ->
    event.preventDefault()
    $form = instance.$(event.target)
    yield_objects = []
    for key, ying of instance.ingyields.all()
      for key, value of ying.yields
        yield_objects.push(yield_id: value.yield._id, amount_taken: value.amount_taken )

    inventory_doc =
      amount: Number( $form.find('[name=amount]').val())
      expiration_date: $form.find('[name=expiration_date]').val()
      yield_objects: yield_objects
      product_id: $form.find('[name=product_id]').val()
    instance.insert inventory_doc


  'mousedown .top': (event, instance) ->
    container = instance.$('.js-selector')
    instance.selector.set('title', null) if  !container.is(event.target) &&
                                    container.has(event.target).length is 0 &&
                                    instance.selector.get('title')?
