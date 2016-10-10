DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
SMethods = require '../../../../api/collections/sells/methods.coffee'
SellModule = require '../../../../api/collections/sells/sells.coffee'
ProductModule = require '../../../../api/collections/products/products.coffee'
InventoryModule = require '../../../../api/collections/inventories/inventories.coffee'



require './update.jade'

class SellsUpdate extends BlazeComponent
  @register 'sellsUpdate'

  mixins: -> [
    DialogMixin
  ]

  constructor: (args) ->
    # body...

  onCreated: ->
    super
    @discountDict = new ReactiveDict
    @discountDict.set('option', '%')
    @discountDict.set('value', true)
    @done = new ReactiveDict
    @sellDoc = new ReactiveVar {total_price: '0.00', sub_total: '0.00', tax_total: '0.00', discount: 0}
    @pDetails = new ReactiveDict


  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')
    clist = @callFirstWith(@, 'clistsDict')
    sell = @sell()
    customer = sell.customer().fetch()[0]
    clist.set "customers", [customer] if customer?
    products = []

    if sell.discount_type
      @discountDict.set('option', '%')
      @discountDict.set('value', true)
    else
      @discountDict.set('option', '$')
      @discountDict.set('value', false)

    for detail in sell.details
      product = ProductModule.Products.findOne detail.product_id
      products.push product
      inventories = []
      pinvs = {}
      for dinv in detail.inventories
        inventories.push InventoryModule.Inventories.findOne dinv.inventory_id
        pinvs[dinv.inventory_id] = dinv.amount_taken

      pdetail =
        quantity: detail.quantity
        unit_price: detail.unit_price
        tax_rate: detail.tax_rate
        inventories: pinvs
      @pDetails.set product._id, pdetail
      clist.set "inventories#{product._id}", inventories

    clist.set "products", products


  sell: ->
    SellModule.Sells.findOne @data().update_id

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  products: ->
    @currentList('products')

  inventories: (product_id) ->
    @currentList("inventories#{product_id}")

  customer: ->
    @currentList('customers')[0]

  unitPrice: (product) ->
    for detail in @sell().details
      if detail.product_id is product._id
        return detail.unit_price

    product.unit_price

  taxRate: (product) ->
    for detail in @sell().details
      if detail.product_id is product._id
        return detail.tax_rate

    product.tax_rate

  invMax: (inventory) ->
    inventory.amount + @defaultInvQuantity(inventory)


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
        unit_price: @unitPrice value
        tax_rate: @taxRate value
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


  getSellDoc: ->
    @sellDoc.get()

  pdetailQuantity: (product_id) ->
    if @pDetails.get(product_id)?
      @pDetails.get(product_id).quantity

  defaultInvQuantity: (inventory) ->
    sell = @sell()
    for detail in sell.details
      if detail.product_id is inventory.product_id
        for inv in detail.inventories
          if inv.inventory_id is inventory._id
            return inv.quantity_taken

    return 1

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
    defaultQuantity = @defaultInvQuantity(inventory)
    if @pDetails.get(inventory.product_id)?
      return inventory.amount - @pDetails.get(inventory.product_id).inventories[inventory._id] + defaultQuantity


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
    classified = @classify()

    $form = $('.js-sell-new-form')
    sell_doc =
      discount: @sellDoc.get().discount
      discount_type: @discountDict.get('value')
      # currency: $form.find('[name=currency]').val()
      details: classified.details
      status: $form.find('[name=status]').val()
      notes: $form.find('[name=notes]').val()
      customer_id: if @customer()? then @customer()._id else null
      # shipping_address:
      # billing_address:
      # telephone:
    @done.set 'putback', false
    @done.set 'add', false
    @update sell_doc, classified.addInventories, classified.putBackInventories

  classify: ->
    details = []
    addInventories = []
    putBackInventories = []

    sPtoI = {}
    for detail in @sell().details
      sPtoI[detail.product_id] = {}
      for inventory in detail.inventories
        sPtoI[detail.product_id][inventory.inventory_id] = inventory


    for pkey, pdetail of @pDetails.all()
      detdoc =
        product_id: pkey
        quantity: pdetail.quantity
      details.push detdoc
      for ikey, pinv of pdetail.inventories
        if sPtoI[pkey]? && sPtoI[pkey][ikey]?
          dif = pinv - sPtoI[pkey][ikey].quantity_taken
          pinventory =
            inventory_id: ikey
            quantity_taken: dif
          addInventories.push pinventory if dif > 0
          if dif < 0
            pinventory.quantity_taken *= -1
            putBackInventories.push pinventory
          delete sPtoI[pkey][ikey]
        else
          pinventory =
            inventory_id: ikey
            quantity_taken: pinv
          addInventories.push pinventory

    for dkey, detail of sPtoI
      unless @pDetails.get(dkey)?
        detdoc =
          product_id: dkey
          quantity: 0
        details.push detdoc
      for ikey, inv of detail
        pinventory =
          inventory_id: ikey
          quantity_taken: inv.quantity_taken
        putBackInventories.push pinventory

    {details: details, addInventories: addInventories, putBackInventories: putBackInventories}



  update: (sell_doc, addInventories, putBackInventories) ->
    organization_id = FlowRouter.getParam 'organization_id'
    sell_id = @data().update_id

    if putBackInventories.length > 0
      @putBackItems(organization_id, sell_id, putBackInventories)
    else
      @done.set('putback', true)

    if addInventories.length > 0
      @addItems(organization_id, sell_id, addInventories)
    else
      @done.set('add', true)

    SMethods.update.call {organization_id, sell_id, sell_doc}, (err, res) =>
      console.log err
      @reRoute(organization_id, sell_id) unless err?


  addItems: (organization_id, sell_id, inventories) ->
    SMethods.addItems.call {organization_id, sell_id, inventories}, (err, res) =>
      console.log err
      @done.set('add', true) unless err?
      @reRoute(organization_id, sell_id)

  putBackItems: (organization_id, sell_id, inventories) =>
    SMethods.putBackItems.call {organization_id, sell_id, inventories}, (err, res) =>
      console.log err
      @done.set('putback', true) unless err?
      @reRoute(organization_id, sell_id)

  reRoute: (organization_id, sell_id) ->
    if @done.get('putback') && @done.get('add')
      $('.js-hide-new').trigger('click')



  events: ->
    super.concat
      'click .js-discount-select': @onToggleDiscount
      'input .js-detail-quantity .pinput': @onDetailQuantity
      'focusout .js-detail-quantity .pinput': @onDetailFocusOut
      'focusout .js-inventory-input .pinput': @onInventoryFocusOut
      'input .js-discount-input .pinput': @onInputDiscount
      'input .js-inventory-input .pinput': @onInputInventory
      'submit .js-sell-update-form': @onSubmit
      'click .js-submit-update-sell': @onSubmit
