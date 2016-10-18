DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'
ErrorComponent = require '../../../mixins/error_mixin.coffee'
IngredientModule= require '../../../../api/collections/ingredients/ingredients.coffee'
IMethods= require '../../../../api/collections/inventories/methods.coffee'
InventoryModule = require '../../../../api/collections/inventories/inventories.coffee'
EMethods = require '../../../../api/collections/events/methods.coffee'

Big = require 'big.js'

require './new.jade'


class InventoriesNew extends ErrorComponent
  @register 'inventoriesNew'

  constructor: (args) ->
    super
    @initAmount = 0

  mixins: ->[ DialogMixin, EventMixin ]

  onCreated: ->
    super
    @iAmounts = new ReactiveDict()
    @schema = InventoryModule.Inventories.simpleSchema()

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')
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
        min: 0
        exclusiveMin: true
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
        min: 0

      event_description:
        type: String
        label: 'description'
        max: 512
        decimal: false
        optional: true
    )


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
    product = @currentList('products')[0]
    @errorDict.set('product_id', false) if product?
    product


  yields: (ingredient_id) ->
    @currentList("yields#{ingredient_id}")


  ingredient: (ping)->
    IngredientModule.Ingredients.findOne ping.ingredient_id


  ingyields: (ingredient_id, amountPre) ->
    @errorDict.set 'ing_mismatch', false
    if @iAmounts.get(ingredient_id)?
      return Number @iAmounts.get(ingredient_id).inv_amount.toFixed(4)
    else
      ingObj =
        inv_amount: 0
        amountPre: amountPre
        yields: {}
      @iAmounts.set(ingredient_id, ingObj)
      return 0


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
      console.log 'asdf'
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

    date =  new Date form.find('[name=expiration_date]').val()
    inventory_doc =
      name: form.find('[name=name]').val()
      amount: Number form.find('[name=amount]').val()
      expiration_date: if isNaN(date.getMonth()) then null else date
      notes: form.find('[name=notes]').val()
      yield_objects: yield_objects
      product_id: if @product()? then @product()._id else null

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
      if err?
        @errorDict.set ed.name, true for ed in err.details
        pins = @findAll('.pinput')
        $(pins).trigger('focusin')
        $(pins).trigger('focusout')

      if res?
        if yield_objects.length > 0
          @packEvent(amount, yield_objects, res, inventory_doc.organization_id)
        else if event_doc?
          event_doc.organization_id = inventory_doc.organization_id
          @userEvent(event_doc, res)
        else
          $('.js-hide-new').trigger('click') unless err?


  packEvent: (amount, yield_objects, inventory_id, organization_id) =>
    EMethods.pack.call {organization_id, inventory_id, yield_objects, amount}, (err, res) =>
      console.log err
      if err?
        @errorDict.set ed.name, true for ed in err.details
        pins = @findAll('.pinput')
        $(pins).trigger('focusin')
        $(pins).trigger('focusout')
      @delete(organization_id, inventory_id) if err?
      $('.js-hide-new').trigger('click') unless err?


  userEvent: (event_doc, inventory_id) =>
    event_doc.for_type = 'inventory'
    event_doc.for_id = inventory_id

    EMethods.userEvent.call {event_doc}, (err, res) =>
      console.log err
      @delete(event_doc.organization_id, inventory_id) if err?
      $('.js-hide-new').trigger('click') unless err?


  delete: (organization_id, inventory_id) =>
    IMethods.delete.call {organization_id, inventory_id}, (err, res) =>
      console.log err


  events: ->
    super.concat
      'input .js-amount-taken': @onInputAT
      'submit .js-inventories-new-form': @onSubmit
      'click .js-submit-new-inventory': @onSubmit
