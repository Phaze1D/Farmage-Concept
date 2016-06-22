{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'
Big = require 'big.js'

# NOT finished need to change
# Add yield be ingredient connect iamount to the min amount of the ingredients
# Remove yield when input is 0

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
InventoryModule = require '../../../api/collections/inventories/inventories.coffee'
ProductModule = require '../../../api/collections/products/products.coffee'
YieldModule = require '../../../api/collections/yields/yields.coffee'

IMethods = require '../../../api/collections/inventories/methods.coffee'
EMethods = require '../../../api/collections/events/methods.coffee'

require '../../products/selector/selector.coffee'
require '../../yields/selector/selector.coffee'
require './new.html'


Template.InventoriesNew.onCreated ->
  @selector = new ReactiveDict
  @ingyields = new ReactiveDict
  @product = new ReactiveVar
  @invAmount = new ReactiveVar(0)



  @selectYield = (yield_id) =>
    _yield = YieldModule.Yields.findOne(yield_id)

    for ping in @product.get().ingredients
      if ping.ingredient_id is _yield.ingredient_id
        ying = @ingyields.get(_yield.ingredient_id)
        ying = camount: 0, yields: {} unless ying?
        ying.yields[yield_id] =
          yield: _yield
          amount_taken: 0
        @ingyields.set(_yield.ingredient_id, ying)
        @checkCAmount(_yield.ingredient_id)
    @selector.set('title', null)



  @selectProduct = (product_id) =>
    @product.set ProductModule.Products.findOne(product_id)
    @selector.set('title', null)


  @checkCAmount = (ingredient_id) =>
    sum = 0
    for key, value of @ingyields.get(ingredient_id).yields
      sum += value.amount_taken

    for ping in @product.get().ingredients
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
      if (amount > 0 || yield_objects.length > 0) && res?
        @packEvent(amount, yield_objects, res, inventory_doc.organization_id)
      else
        params =
          organization_id: inventory_doc.organization_id
        FlowRouter.go('inventories.index', params ) unless err?

  @packEvent = (amount, yield_objects, inventory_id, organization_id) =>
    EMethods.pack.call {organization_id, inventory_id, yield_objects, amount}, (err, res) =>
      console.log err
      @deleteEvent(organization_id, inventory_id) if err?
      params =
        organization_id: organization_id
      FlowRouter.go('inventories.index', params ) unless err?

  @deleteEvent = (organization_id, inventory_id) =>
    IMethods.delete.call {organization_id, inventory_id}, (err, res) =>
      console.log err


Template.InventoriesNew.helpers
  selector: ->
    instance = Template.instance()
    ret =
      title: instance.selector.get('title')
      select:
        select: instance[instance.selector.get('select')]

  yields: (ingredient_id) ->
    ying = Template.instance().ingyields.get(ingredient_id)
    (value for key, value of ying.yields) if ying?


  product: ->
    Template.instance().product.get()

  invAmount: ->
    Template.instance().invAmount.get()

  camount: (ingredient_id) ->
    ying = Template.instance().ingyields.get(ingredient_id)
    ying.camount if ying?


Template.InventoriesNew.events

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

  'focusin .js-input-products': (event, instance) ->
    instance.selector.set 'title', 'ProductsSelector'
    instance.selector.set 'select', 'selectProduct'
    instance.product.set null


  'mousedown .top': (event, instance) ->
    container = instance.$('.js-selector')
    instance.selector.set('title', null) if  !container.is(event.target) &&
                                    container.has(event.target).length is 0 &&
                                    instance.selector.get('title')?


  'change .js-at-input': (event, instance) ->
    ingredient_id = instance.$(event.target).closest('.js-ingredient').attr('data-id')
    yield_id = instance.$(event.target).closest('.js-yield').attr('data-id')
    ying = instance.ingyields.get(ingredient_id)
    ying.yields[yield_id].amount_taken = Number ($(event.target).val())
    instance.ingyields.set(ingredient_id, ying)
    instance.checkCAmount ingredient_id



  'change .js-iamount-input': (event, instance) ->
    $input = $(event.target)
    instance.invAmount.set Number($input.val())


  'submit .js-inventories-form-new': (event, instance) ->
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
