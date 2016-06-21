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
require './new.html'


Template.InventoriesNew.onCreated ->
  @selector = new ReactiveDict
  @yields = new ReactiveVar([])
  @product = new ReactiveVar
  @proIngDict = new ReactiveDict
  @invAmount = new ReactiveVar(0)

  @removeYield = (index) =>
    ylds = (_yield for _yield, i in @yields.get() when i isnt Number index )
    @yields.set ylds
    @checkAmount()


  @selectYield = (yield_id) =>
    return for _yield in @yields.get() when _yield.yield_id is yield_id
    ylds = @yields.get()
    yld = YieldModule.Yields.findOne yield_id
    if @proIngDict.get(yld.ingredient_id)?
      ylds.push {yield_id: yld._id, yield: yld, amount_taken: 0}
      @yields.set ylds
    @selector.set('title', null)


  @selectProduct = (product_id) =>
    @product.set ProductModule.Products.findOne product_id
    @proIngDict.set(ing.ingredient_id, {ingredient: ing, cAmount: 0}) for ing in @product.get().ingredients
    @selector.set 'title', null


  @checkAmount = =>
    sums = {}
    for _yield in @yields.get()
      if sums[_yield.yield.ingredient_id]?
        sums[_yield.yield.ingredient_id] += _yield.amount_taken
      else
        sums[_yield.yield.ingredient_id] = _yield.amount_taken

    i = 0
    prev = 0
    for key, value of @proIngDict.all()
      value.cAmount = if sums[key]? then Number new Big(sums[key]).div(value.ingredient.amount) else 0
      @proIngDict.set(key, value)

      unless value.cAmount is @invAmount.get()
        console.warn "Warn users ingredient amounts not matching"
      unless value.cAmount % 1 is 0
        console.warn "Warn user that ingredient product amount has to be an integer"
      i++

  @insert = (inventory_doc) =>
    yield_objects = inventory_doc.yield_objects
    amount = inventory_doc.amount
    delete inventory_doc.amount
    delete inventory_doc.yield_objects
    inventory_doc.organization_id = FlowRouter.getParam('organization_id')

    IMethods.insert.call {inventory_doc}, (err, res) =>
      console.log err
      if amount > 0 && res?
        @packEvent(amount, yield_objects, res, inventory_doc.organization_id)
      else
        params =
          organization_id: inventory_doc.organization_id
        FlowRouter.go('inventories.index', params ) if amount <= 0 && !err?

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

  yields: ->
    Template.instance().yields.get()

  product: ->
    Template.instance().product.get()

  invAmount: ->
    Template.instance().invAmount.get()

  ingAmount: (ingredient_id) ->
    Template.instance().proIngDict.get(ingredient_id).cAmount

Template.InventoriesNew.events

  'click .js-yield-remove': (event, instance) ->
    index =  instance.$(event.target).closest('.js-yield').attr('data-index')
    instance.removeYield index

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
    $input = $(event.target)
    for _yield in instance.yields.get()
      if _yield.yield_id is $input.attr('data-id')
        _yield.amount_taken = Number($input.val())

    instance.yields.set instance.yields.get()
    instance.checkAmount()


  'change .js-iamount-input': (event, instance) ->
    $input = $(event.target)
    instance.invAmount.set Number($input.val())


  'submit .js-inventories-form-new': (event, instance) ->
    event.preventDefault()
    $form = instance.$(event.target)
    yield_objects = []
    for _yield in instance.yields.get()
      yield_objects.push {yield_id: _yield.yield_id, amount_taken: _yield.amount_taken}
    inventory_doc =
      amount: Number( $form.find('[name=amount]').val())
      expiration_date: $form.find('[name=expiration_date]').val()
      yield_objects: yield_objects
      product_id: $form.find('[name=product_id]').val()
    instance.insert inventory_doc
