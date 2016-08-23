DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'

IngredientModule= require '../../../../api/collections/ingredients/ingredients.coffee'
IMethods= require '../../../../api/collections/inventories/methods.coffee'


Big = require 'big.js'

require './new.jade'


class InventoriesNew extends BlazeComponent
  @register 'inventoriesNew'

  constructor: (args) ->

  mixins: ->[
    EventMixin, DialogMixin
  ]

  onCreated: ->
    super
    @iAmounts = new ReactiveDict()

  onRendered: ->
    super
    @autorun =>
      product = @product()
      if product?
        @subscribe "product.ingredients", product.organization_id, product._id,
          onStop: (err) ->
            console.log "sub stop #{err}"
          onReady: ->

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);


  getMainAmount: ->
    return @callFirstWith(@, 'getMainAmount');


  setMainAmount: ->
    min = null
    for key, value of @iAmounts.all()
      unless min?
        min = value.inv_amount

      if min > value.inv_amount
        min = value.inv_amount

    return @callFirstWith(@, 'setMainAmount', min);


  product: ->
    @currentList('products')[0]


  yields: (ingredient_id) ->
    @currentList("yields#{ingredient_id}")


  ingredient: (ping)->
    IngredientModule.Ingredients.findOne ping.ingredient_id


  ingyields: (ingredient_id, amountPre) ->
    if @iAmounts.get(ingredient_id)?
      return @iAmounts.get(ingredient_id).inv_amount
    else
      ingObj =
        inv_amount: 0
        amountPre: amountPre
        yields: {}
      @iAmounts.set(ingredient_id, ingObj)
      return 0


  addYield: (ingredient_id, yield_id) ->
    ingObj = @iAmounts.get(ingredient_id)
    unless ingObj.yields[yield_id]?
      ingObj.yields[yield_id] = 0
    @iAmounts.set(ingredient_id, ingObj)


  currentYieldAmount: (ingredient_id, yield_id, amount) ->
    amount - @iAmounts.get(ingredient_id).yields[yield_id]


  onHideCallback: =>
    all = @iAmounts.all()
    for ikey, ivalue of all
      ivalue.inv_amount = 0
      if @find(".ing-section[data-ingredient='#{ikey}']")
        for ykey, yvalue of ivalue.yields
          if @find(".yield-input-sec[data-yield='#{ykey}']")?
            ivalue.inv_amount += Number( new Big(yvalue).div(ivalue.amountPre) )
          else
            delete ivalue.yields[ykey]
        @iAmounts.set ikey, ivalue
      else
        @iAmounts.delete(ikey)

  isEventHidden: ->
    @callFirstWith(@, 'isEventHidden')

  hideEvent: ->
    unless @isEventHidden()
      @callFirstWith(@, 'hideEvent')


  onShowEvent: ->
    clists = @callFirstWith(@, 'clistsDict')
    products = clists.get('products')
    clists.clear()
    clists.set('products', products)
    @iAmounts.clear()


  onInputAT: (event) ->
    tar = $(event.currentTarget)
    yield_id = tar.closest('.yield-input-sec').attr('data-yield')
    ingredient_id = tar.closest('.yield-input-sec').attr('data-ingredient')
    ingObj = @iAmounts.get(ingredient_id)
    ingObj.yields[yield_id] = Number tar.find('.pinput').val()
    ingObj.inv_amount = 0
    for key, value of ingObj.yields
      if @find(".yield-input-sec[data-yield='#{key}']")?
        ingObj.inv_amount += Number( new Big(value).div(ingObj.amountPre) )
      else
        delete ingObj.yields[key]
    @iAmounts.set(ingredient_id, ingObj)
    @hideEvent()


  onSubmit: (event) ->
    event.preventDefault()
    form = $('.js-inventories-new-form')

    yield_objects = []
    for ik, iv of @iAmounts.all()
      for yk, yv of iv.yields
        yield_objects.push yield_id: yk, amount_taken: yv

    inventory_doc =
      name: form.find('[name=name]').val()
      amount: Number form.find('[name=amount]').val()
      expiration_date: form.find('[name=expiration_date]').val()
      notes: form.find('[name=notes]').val()
      yield_objects: yield_objects
      product_id: @product()._id

    event_doc = null
    unless @isEventHidden()
      event_doc =
        amount: Number form.find('[name=event_amount]').val()
        description: form.find('[name=event_description]').val()

    @insert inventory_doc, event_doc

  insert: (inventory_doc, event_doc) ->
    amount = inventory_doc.amount
    yield_objects = inventory_doc.yield_objects
    delete inventory_doc.amount
    delete inventory_doc.yield_objects
    inventory_doc.organization_id = FlowRouter.getParam('organization_id')
    
    IMethods.insert.call {inventory_doc}, (err, res) =>
      console.log err
      if res?
        if yield_objects.length > 0
          @packEvent(amount, yield_objects, res, inventory_doc.organization_id)
        else if @event.get()? && @event.get().amount > 0
          @userEvent(res)
        else
          params =
            organization_id: inventory_doc.organization_id
          FlowRouter.go('inventories.index', params ) unless err?



  events: ->
    super.concat
      'input .js-amount-taken': @onInputAT
      'submit .js-inventories-new-form': @onSubmit
