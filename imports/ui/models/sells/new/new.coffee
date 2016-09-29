
DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
SMethods = require '../../../../api/collections/sells/methods.coffee'


require './new.jade'


class SellsNew extends BlazeComponent
  @register 'sellsNew'

  mixins: -> [
    DialogMixin
  ]

  constructor: (args) ->
    # body...

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  onCreated: ->
    super
    @discountDict = new ReactiveDict
    @discountDict.set('option', '%')
    @discountDict.set('value', true)

    @sellDoc = new ReactiveVar {total_price: '0.00', sub_total: '0.00', tax_total: '0.00', discount: 0}
    @pDetails = new ReactiveDict


  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);


  products: ->
    @currentList('products')


  inventories: (product_id) ->
    @currentList("inventories#{product_id}")

  date: (date) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

  invIdentifier: (inventory) ->
    if inventory.name?
      return inventory.name
    else
      return inventory._id


  discountType: ->
    @discountDict.all()


  initPDetails: (products) ->
    productDict = @convertToDict products, '_id'

    for key, value of productDict
      pdetail =
        quantity: 1
        unit_price: value.unit_price
        tax_rate: value.tax_rate
        inventories: {}

      unless @pDetails.get(key)?
        @pDetails.set key, pdetail

    for key, value of @pDetails.all()
      unless productDict[key]?
        @pDetails.delete(key)


  convertToDict: (array, key) ->
    dic = {}
    for item in array
      if item[key]?
        dic[item[key]] = item
    dic


  subTotal: (product_id) ->
    pd = @pDetails.get(product_id)
    if pd?
      st = pd.unit_price * pd.quantity * (1 + (pd.tax_rate/100))
      '$'+ st.toFixed(2)


  calculateSell: ->
    sd =
      sub_total: 0
      tax_total: 0
      total_price: 0
      discount: @sellDoc.get().discount

    for key, value of @pDetails.all()
      sd.sub_total += (value.unit_price * value.quantity)
      sd.tax_total += (value.unit_price * value.quantity) * (value.tax_rate/100)

    sd.total_price = sd.sub_total + sd.tax_total

    if @discountDict.get('value')
      sd.discount = if sd.discount <= 100 then sd.discount else 100
      sd.total_price = sd.total_price - (sd.total_price * sd.discount/100)
    else if sd.total_price > sd.discount
        sd.total_price = sd.total_price - sd.discount
    else if sd.total_price < sd.discount
      sd.total_price = 0

    sd.total_price = sd.total_price.toFixed(2)
    sd.sub_total = sd.sub_total.toFixed(2)
    sd.tax_total = sd.tax_total.toFixed(2)
    @sellDoc.set sd


  sell: ->
    @sellDoc.get()

  pdetailQuantity: (product_id) ->
    if @pDetails.get(product_id)?
      @pDetails.get(product_id).quantity

  initInventories: ->
    for pdkey, pdvalue of @pDetails.all()
      cInvDict = @convertToDict @currentList("inventories#{pdkey}"), '_id'

      for cikey, civalue of cInvDict
        unless pdvalue.inventories[cikey]?
          pdvalue.inventories[cikey] = 1

      quantity = 0
      for pikey, pivalue of pdvalue.inventories
        if cInvDict[pikey]?
            quantity += pdvalue.inventories[pikey]
        else
          delete pdvalue.inventories[pikey]

      if !_.isEmpty(pdvalue.inventories)
        pdvalue.quantity = quantity
      else if pdvalue.quantity <= 0
        pdvalue.quantity = 1

      @pDetails.set(pdkey, pdvalue)

  invAvailable: (inventory) ->
    if @pDetails.get(inventory.product_id)?
      return inventory.amount - @pDetails.get(inventory.product_id).inventories[inventory._id]


  removeProduct: (product_id) ->
    clistsDict = @callFirstWith(@, 'clistsDict');
    products = clistsDict.get('products')
    np = []
    np.push prod for prod in products when prod._id isnt product_id
    clistsDict.set('products', np)
    @onCloseDialogCallback()

  removeInventory: (product_id, inventory_id) ->
    clistsDict = @callFirstWith(@, 'clistsDict');
    inventories = clistsDict.get("inventories#{product_id}")
    np = []
    np.push inv for inv in inventories when inv._id isnt inventory_id
    clistsDict.set("inventories#{product_id}", np)
    @onCloseDialogCallback()


  disableDetail: (product_id) ->
    if @pDetails.get(product_id)? && !_.isEmpty(@pDetails.get(product_id).inventories)
      return 'true'
    return

  canPay: ->
    disabled = false
    disabled = true for key, value of @pDetails.all() when _.isEmpty value.inventories
    return 'true' if disabled || _.isEmpty @pDetails.all()

  onCloseDialogCallback: =>
    products = @currentList('products')
    @initPDetails(products)
    @initInventories()
    @calculateSell()



  onDetailQuantity: (event) ->
    tar = $(event.currentTarget)
    id = tar.closest('.product-box').attr('data-id')
    pd = @pDetails.get(id)
    value = if tar.val().length > 0 then Number tar.val() else 0
    pd.quantity = value
    @pDetails.set id, pd
    @calculateSell()


  onToggleDiscount: (event) ->
    if @discountDict.get('value')
      @discountDict.set('option', '$')
      @discountDict.set('value', false)
    else
      @discountDict.set('option', '%')
      @discountDict.set('value', true)
    @calculateSell()


  onInputDiscount: (event) ->
    sd = @sellDoc.get()
    value = if event.currentTarget.value.length > 0 then Number event.currentTarget.value else 0
    sd.discount = value
    @sellDoc.set(sd)
    @calculateSell()


  onDetailFocusOut: (event) ->
    tar = $(event.currentTarget)
    value = tar.val()
    product_id = tar.closest('.product-box').attr('data-id')
    if (value.length > 0 && Number value <= 0) or value.length is 0
      @removeProduct(product_id)


  onInputInventory: (event) ->
    tar = $(event.currentTarget)
    value = if tar.val().length > 0 then Number tar.val() else 0
    inv_id = tar.closest('.inventory-box').attr('data-id')
    product_id = tar.closest('.product-box').attr('data-id')
    pd = @pDetails.get(product_id)
    pd.inventories[inv_id] = Number value

    quantity = 0
    for key, value of pd.inventories
      quantity+= value

    pd.quantity = quantity
    @pDetails.set(product_id, pd)
    @calculateSell()


  onInventoryFocusOut: (event) ->
    tar = $(event.currentTarget)
    value = tar.val()
    product_id = tar.closest('.product-box').attr('data-id')
    inv_id = tar.closest('.inventory-box').attr('data-id')
    if (value.length > 0 && Number value <= 0) or value.length is 0
      @removeInventory(product_id, inv_id)


  onSubmit: (event) ->
    event.preventDefault()
    inventories = []
    details = []
    for pkey, pdetail of @pDetails.all()
      detdoc =
        product_id: pkey
        quantity: pdetail.quantity
      details.push detdoc
      for ikey, value of pdetail.inventories
        invdoc =
          inventory_id: ikey
          quantity_taken: value
        inventories.push invdoc

    $form = $('.js-sell-new-form')
    sell_doc =
      discount: @sellDoc.get().discount
      discount_type: @discountDict.get('value')
      # currency: $form.find('[name=currency]').val()
      details: details
      status: $form.find('[name=status]').val()
      notes: $form.find('[name=notes]').val()
      # customer_id:
      # shipping_address:
      # billing_address:
      # telephone:

    @insert sell_doc, inventories


  insert: (sell_doc, inventories) ->
    sell_doc.organization_id = FlowRouter.getParam('organization_id')
    SMethods.insert.call {sell_doc}, (err, res) =>
      console.log err
      if inventories.length > 0 and res?
        @addItems(sell_doc.organization_id, res, inventories)
      else
        $('.js-hide-new').trigger('click') unless err?

  addItems: (organization_id, sell_id, inventories) ->
    SMethods.addItems.call {organization_id, sell_id, inventories}, (err, res) =>
      console.log err
      if err?
        @remove(organization_id, sell_id)
      else
        $('.js-hide-new').trigger('click') unless err?

  remove: (organization_id, sell_id) =>
    SMethods.remove.call {organization_id, sell_id}, (err, res) ->
      console.log err


  events: ->
    super.concat
      'click .js-discount-select': @onToggleDiscount
      'input .js-detail-quantity .pinput': @onDetailQuantity
      'focusout .js-detail-quantity .pinput': @onDetailFocusOut
      'focusout .js-inventory-input .pinput': @onInventoryFocusOut
      'input .js-discount-input .pinput': @onInputDiscount
      'input .js-inventory-input .pinput': @onInputInventory
      'submit .js-sell-new-form': @onSubmit
      'click .js-submit-new-sell': @onSubmit
