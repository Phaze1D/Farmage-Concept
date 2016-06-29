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

  @uninv_id = FlowRouter.getParam 'child_id'


  @subCallback =
    onStop: (err) =>
      console.log "inventories update stop #{err}"
    onReady: () =>
      console.log "onReady"
      @intialYield()


  @autorun =>
    console.log autorun: 'atads'
    @inventory.set InventoryModule.Inventories.findOne @uninv_id
    @subscribe 'inventory.parents', @inventory.get().organization_id, @inventory.get()._id, @subCallback

    @product.set @inventory.get().product().fetch()[0]
    @amounts.set 'inamount', @inventory.get().amount
    @amounts.set 'chamount', 0

  @intialYield = () =>
    for yield_item in @inventory.get().yield_objects
      _yield = YieldModule.Yields.findOne yield_item.yield_id
      ying = @ingyields.get(_yield.ingredient_id)
      ying = camount: 0, yields: {} unless ying?
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
      sum += (value.amount_taken - value.min)

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

    if min?
      @amounts.set 'chamount', min.camount
      @amounts.set 'inamount', @inventory.get().amount + min.camount



  @update = (inventory_doc) =>
    yield_objects = inventory_doc.yield_objects
    amount = @amounts.get 'chamount'

    delete inventory_doc.amount
    delete inventory_doc.yield_objects

    inventory_id = FlowRouter.getParam 'child_id'
    organization_id = FlowRouter.getParam('organization_id')

    IMethods.update.call {organization_id, inventory_id, inventory_doc}, (err, res) =>
      console.log err
      if res?
        if yield_objects.length > 0
          @packEvent(amount, yield_objects, inventory_id, organization_id)
        else if @event.get()? && @event.get().amount > 0
          @userEvent(inventory_id)
        else
          params =
            organization_id: organization_id
            child_id: inventory_id
          FlowRouter.go('inventories.show', params ) unless err?


  @packEvent = (amount, yield_objects, inventory_id, organization_id) =>
    EMethods.pack.call {organization_id, inventory_id, yield_objects, amount}, (err, res) =>
      console.log err
      params =
        organization_id: organization_id
        child_id: inventory_id
      FlowRouter.go('inventories.show', params ) unless err?



  @userEvent = (inventory_id) =>
    event_doc = @event.get()
    event_doc.for_type = 'inventory'
    event_doc.for_id = inventory_id
    event_doc.organization_id = FlowRouter.getParam 'organization_id'

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      params =
        organization_id: event_doc.organization_id
        child_id: inventory_id
      FlowRouter.go('inventories.show', params ) unless err?



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

  max: (min, amount) ->
    min + amount


Template.InventoriesUpdate.events

  'click .js-yield-remove': (event, instance) ->
    ingredient_id = instance.$(event.target).closest('.js-ingredient').attr('data-id')
    jsyield = instance.$(event.target).closest('.js-yield')
    yield_id = jsyield.attr('data-id')
    ying = instance.ingyields.get(ingredient_id)
    if ying.yields[yield_id].min > 0
      ying.yields[yield_id].amount_taken = ying.yields[yield_id].min
      jsyield.find('.js-at-input').val(ying.yields[yield_id].min)
    else
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
    ymin = ying.yields[yield_id].min
    ying.yields[yield_id].amount_taken = if value < ymin then ymin else value
    instance.$(event.target).val(ymin) if value < ymin
    instance.ingyields.set(ingredient_id, ying)
    instance.checkCAmount ingredient_id

  'click .js-changeM-b': (event, instance) ->
    instance.change.set('packing', false)
    instance.change.set('manually', true) if instance.product.get()?
    instance.event.set null
    inyiels = instance.ingyields.all()
    for ikey, ing of inyiels
      for ykey, yiel of ing.yields
          ying = instance.ingyields.get(ikey)
          if yiel.min is 0
            delete ying.yields[ykey]
          else
            ying.yields[ykey].amount_taken = ying.yields[ykey].min
          instance.ingyields.set(ikey, ying)
      instance.checkCAmount ikey
    instance.amounts.set 'chamount', 0
    instance.amounts.set 'inamount', instance.inventory.get().amount


  'click .js-changeP-b': (event, instance) ->
    instance.change.set('manually', false)
    instance.event.set null
    instance.amounts.set 'chamount', 0
    instance.amounts.set 'inamount', instance.inventory.get().amount
    instance.change.set('packing', true)

  'change .js-mamount-input': (event, instance) ->
    value = Number instance.$(event.target).val()
    if value < -instance.inventory.get().amount
      instance.$(event.target).val -instance.inventory.get().amount
      value = -instance.inventory.get().amount

    instance.amounts.set 'chamount', value
    instance.amounts.set 'inamount', instance.inventory.get().amount + value

  'click .js-apply-event': (event, instance) ->
    value = Number instance.amounts.get 'chamount'
    $form = instance.$('.js-inventories-form-update')
    instance.change.set 'manually', false
    if value isnt 0
      event_doc =
        amount: value
        description: $form.find('[name=event_description]').val()
      instance.event.set event_doc


  'click .js-cancel-event': (event, instance) ->
    instance.amounts.set 'chamount', 0
    instance.amounts.set 'inamount', instance.inventory.get().amount
    instance.event.set null
    instance.change.set 'manually', false



  'submit .js-inventories-form-update': (event, instance) ->
    event.preventDefault()
    $form = instance.$(event.target)
    yield_objects = []
    for key, ying of instance.ingyields.all()
      for key, value of ying.yields
        if value.amount_taken - value.min > 0
          yield_objects.push(yield_id: value.yield._id, amount_taken: value.amount_taken - value.min)

    inventory_doc =
      expiration_date: $form.find('[name=expiration_date]').val()
      yield_objects: yield_objects
    instance.update inventory_doc


  'mousedown .top': (event, instance) ->
    container = instance.$('.js-selector')
    instance.selector.set('title', null) if  !container.is(event.target) &&
                                    container.has(event.target).length is 0 &&
                                    instance.selector.get('title')?
