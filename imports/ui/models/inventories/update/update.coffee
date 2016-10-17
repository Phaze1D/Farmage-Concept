DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'
IngredientModule = require '../../../../api/collections/ingredients/ingredients.coffee'
InventoryModule = require '../../../../api/collections/inventories/inventories.coffee'
IMethods= require '../../../../api/collections/inventories/methods.coffee'
EMethods = require '../../../../api/collections/events/methods.coffee'

Big = require 'big.js'

require './update.jade'

class InventoriesUpdate extends BlazeComponent
  @register 'inventoriesUpdate'

  constructor: (args) ->
    super

  mixins: ->[ DialogMixin, EventMixin ]

  onCreated: ->
    super
    @initAmount = @inventory().amount
    @iAmounts = new ReactiveDict()
    @schema = InventoryModule.Inventories.simpleSchema()


  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')
    clist = @callFirstWith(@, 'clistsDict')
    product = @inventory().product().fetch()[0]
    clist.set 'products', [product]

    @autorun =>
      product = @product()
      if product?
        @subscribe "ingredients", product.organization_id, 'product', product._id,
          onStop: (err) ->
            console.log "sub stop #{err}"
          onReady: ->


  cYieldSchema: (max) ->
    new SimpleSchema(
      amount_taken:
        type: Number
        decimal: true
        max: max
    )

  eventSchema: ->
    new SimpleSchema(
      amount:
        type: Number
        label: 'amount'
        decimal: false
        min: 0

      event_amount:
        type: Number
        label: 'amount'
        decimal: false
        optional: true
        min: -@inventory().amount

      event_description:
        type: String
        label: 'description'
        max: 512
        decimal: false
        optional: true
    )


  inventory: ->
    InventoryModule.Inventories.findOne @data().update_id


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

    min += @initAmount
    return @callFirstWith(@, 'setMainAmount', min);


  product: ->
    @currentList('products')[0]


  yields: (ingredient_id) ->
    @currentList("yields#{ingredient_id}")


  ingredient: (ping)->
    IngredientModule.Ingredients.findOne ping.ingredient_id


  ingyields: (ingredient_id, amountPre) ->
    if @iAmounts.get(ingredient_id)?
      return Number( (@iAmounts.get(ingredient_id).inv_amount + @initAmount).toFixed(4) )
    else
      ingObj =
        inv_amount: 0
        amountPre: amountPre
        yields: {}
      @iAmounts.set(ingredient_id, ingObj)
      return @initAmount


  addYield: (ingredient_id, yield_id) ->
    ingObj = @iAmounts.get(ingredient_id)
    if ingObj? && !ingObj.yields[yield_id]?
      ingObj.yields[yield_id] = 0
    @iAmounts.set(ingredient_id, ingObj)
    return


  currentYieldAmount: (ingredient_id, yield_id, amount) ->
    amount - @iAmounts.get(ingredient_id).yields[yield_id]


  onHideCallback: =>



  onCloseDialogCallback: =>
    list = @callFirstWith(@, 'currentList')
    parentID = @callFirstWith(@, 'getParentID')
    listDict = @convertToDict(list, '_id')

    ingObj = @iAmounts.get(parentID)
    if ingObj?
      ingObj.inv_amount = 0

      for _yield in list
        @addYield(parentID, _yield._id)

      for key, value of ingObj.yields
        if listDict[key]?
          ingObj.inv_amount += Number( new Big(value).div(ingObj.amountPre) )
        else
          delete ingObj.yields[key]

      @iAmounts.set(parentID, ingObj)
    else
      @iAmounts.clear()


  convertToDict: (array, key) ->
    dic = {}
    for item in array
      if item[key]?
        dic[item[key]] = item
    dic

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
    form = $('.js-inventories-update-form')
    yield_objects = []
    for ik, iv of @iAmounts.all()
      for yk, yv of iv.yields
        yield_objects.push yield_id: yk, amount_taken: yv

    amount = Number(form.find('[name=amount]').val()) - @initAmount
    inventory_doc =
      name: form.find('[name=name]').val()
      amount: amount
      expiration_date: form.find('[name=expiration_date]').val()
      notes: form.find('[name=notes]').val()
      yield_objects: yield_objects

    event_doc = null
    unless @isEventHidden()
      event_doc =
        amount: Number form.find('[name=event_amount]').val()
        description: form.find('[name=event_description]').val()

    @update inventory_doc, event_doc


  update: (inventory_doc, event_doc) ->
    amount = inventory_doc.amount
    yield_objects = inventory_doc.yield_objects
    delete inventory_doc.amount
    delete inventory_doc.yield_objects
    organization_id = FlowRouter.getParam('organization_id')
    inventory_id = @data().update_id
    IMethods.update.call {organization_id, inventory_id, inventory_doc}, (err, res) =>
      console.log err
      unless err?
        if yield_objects.length > 0
          @packEvent(amount, yield_objects, inventory_id, organization_id)
        else if event_doc?
          event_doc.organization_id = organization_id
          @userEvent(event_doc, inventory_id)
        else
          $('.js-hide-new').trigger('click') unless err?


  packEvent: (amount, yield_objects, inventory_id, organization_id) =>
    EMethods.pack.call {organization_id, inventory_id, yield_objects, amount}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  userEvent: (event_doc, inventory_id) =>
    event_doc.for_type = 'inventory'
    event_doc.for_id = inventory_id

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  events: ->
    super.concat
      'input .js-amount-taken': @onInputAT
      'submit .js-inventories-update-form': @onSubmit
      'click .js-submit-update-inventory': @onSubmit
