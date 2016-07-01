{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
SellModule = require '../../../api/collections/sells/sells.coffee'
ProductModule = require '../../../api/collections/products/products.coffee'
InventoryModule = require '../../../api/collections/inventories/inventories.coffee'
CustomerModule = require '../../../api/collections/customers/customers.coffee'

SMethods = require '../../../api/collections/sells/methods.coffee'

require '../../customers/selector/selector.coffee'
require '../../products/selector/selector.coffee'
require '../../inventories/selector/selector.coffee'
require './update.html'


Template.SellsUpdate.onCreated ->
  @selector = new ReactiveDict(detail: 'false', customer: 'false', inventory: 'false', rinvent: 'false')
  @customer = new ReactiveVar
  @pdetails = new ReactiveDict
  @totals = new ReactiveDict(sub_total: '0.00', tax_total: '0.00', total_price: '0.00', discount: '0', discount_type: "true")
  @contact = new ReactiveDict
  @pay = new ReactiveVar(false)
  @sell = new ReactiveVar
  @done = new ReactiveDict

  unsell_id = FlowRouter.getParam 'child_id'
  organ_id = FlowRouter.getParam 'organization_id'

  @subCallback =
    onStop: (err) =>
      console.log "sells update stop #{err}"
    onReady: () =>
      console.log "onReady"
      @contact.set 'address', @sell.get().shipping_address
      @contact.set 'telephone', @sell.get().telephone

      for detail in @sell.get().details
        @selectProduct detail.product_id, detail.quantity
        for inventory in detail.inventories
          @selectInventory inventory.inventory_id, inventory.quantity_taken

  @autorun =>
    @sell.set SellModule.Sells.findOne unsell_id
    @subscribe 'sell.parents', @sell.get().organization_id, @sell.get()._id, @subCallback
    @customer.set @sell.get().customer().fetch()[0]





  @selectProduct = (product_id, quantity = 1) =>
    product = ProductModule.Products.findOne product_id
    pdetail =
      product: product
      quantity: quantity
      inventories: {}
    @pdetails.set(product_id, pdetail) unless @pdetails.get(product_id)?
    @setTotals()
    @selector.set(detail: false, customer: false, inventory: false)


  @selectInventory = (inventory_id, quantity_taken = 1) =>
    inventory = InventoryModule.Inventories.findOne inventory_id
    dinventory =
      inventory: inventory
      quantity_taken: quantity_taken

    pdetail = @pdetails.get(inventory.product_id)
    if pdetail?
      if pdetail.inventories[inventory._id]?
        pdetail.inventories[inventory._id].quantity_taken+= quantity_taken
      else
        pdetail.inventories[inventory._id] = dinventory
      pdetail.disabled = disabled: true
      pdetail.quantity = 0
      pdetail.quantity += value.quantity_taken for key, value of pdetail.inventories
      @pdetails.set(inventory.product_id, pdetail)

    unless pdetail?
      product = ProductModule.Products.findOne inventory.product_id
      if product?
        pdetail =
          product: product
          quantity: quantity_taken
          inventories: {}
          disabled: disabled: true
        pdetail.inventories[inventory._id] = dinventory
        @pdetails.set(inventory.product_id, pdetail)
    @setTotals()
    @selector.set(detail: false, customer: false, inventory: false)


  @selectCustomer = (customer_id) =>
    customer = CustomerModule.Customers.findOne(customer_id)
    @customer.set(customer)
    @selector.set(detail: false, customer: false, inventory: false)


  @setTotals = =>
    sub_total = 0
    tax_total = 0
    for key, value of @pdetails.all()
      sub_total += value.product.unit_price * value.quantity
      tax_total += (value.product.unit_price * value.quantity) * (value.product.tax_rate/100)

    total_price = sub_total + tax_total
    discount = @totals.get('discount')
    discount_type = @totals.get('discount_type')
    if discount_type
      discount = if discount <= 100 then discount else 100
      total_price = total_price - (total_price * discount/100)
    else if total_price > discount
      total_price = total_price - discount
    else if total_price < discount
      total_price = 0

    totals =
      sub_total: sub_total.toFixed(2)
      tax_total: tax_total.toFixed(2)
      total_price: total_price.toFixed(2)

    @totals.set(totals)

  @update = (sell_doc, addInventories, putBackInventories) =>
    organization_id = FlowRouter.getParam 'organization_id'
    sell_id = FlowRouter.getParam 'child_id'

    SMethods.update.call {organization_id, sell_id, sell_doc}, (err, res) =>
      console.log err

      if addInventories.length > 0
        @addItems(organization_id, sell_id, addInventories) unless err?
      else
        @done.set('add', true)

      if putBackInventories.length > 0
        @putBackItems(organization_id, sell_id, putBackInventories) unless err?
      else
        @done.set('putback', true)

      @reRoute(organization_id, sell_id)


  @addItems = (organization_id, sell_id, inventories) =>
    SMethods.addItems.call {organization_id, sell_id, inventories}, (err, res) =>
      console.log err
      @done.set('add', true) unless err?
      @reRoute(organization_id, sell_id)

  @putBackItems = (organization_id, sell_id, inventories) =>
    SMethods.putBackItems.call {organization_id, sell_id, inventories}, (err, res) =>
      console.log err
      @done.set('putback', true) unless err?
      @reRoute(organization_id, sell_id)

  @reRoute = (organization_id, sell_id) =>
    if @done.get('putback') && @done.get('add')
      params =
        organization_id: organization_id
        child_id: sell_id
      if @pay.get()
        FlowRouter.go('sells.update.pay', params ) unless err?
      else
        FlowRouter.go('sells.show', params ) unless err?


  @classify = =>
    details = []
    addInventories = []
    putBackInventories = []

    sPtoI = {}
    for detail in @sell.get().details
      sPtoI[detail.product_id] = {}
      for inventory in detail.inventories
        sPtoI[detail.product_id][inventory.inventory_id] = inventory


    for pkey, pdetail of @pdetails.all()
      detdoc =
        product_id: pdetail.product._id
        quantity: pdetail.quantity
      details.push detdoc
      for ikey, pinv of pdetail.inventories
        if sPtoI[pkey]? && sPtoI[pkey][ikey]?
          dif = pinv.quantity_taken - sPtoI[pkey][ikey].quantity_taken
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
            quantity_taken: pinv.quantity_taken
          addInventories.push pinventory

    for dkey, detail of sPtoI
      unless @pdetails.get(dkey)?
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

  @remove = (organization_id, sell_id) =>
    SMethods.remove.call {organization_id, sell_id}, (err, res) ->
      console.log err

Template.SellsUpdate.helpers
  sell: ->
    Template.instance().sell.get()

  pdetails: ->
    pdetails = Template.instance().pdetails.all()
    (value for key, value of pdetails)

  inventories: (pdetail) ->
    (value for key, value of pdetail.inventories)

  canPay: ->
    pdetails = Template.instance().pdetails.all()
    disable = false
    disable = true for key, value of pdetails when _.isEmpty(value.inventories)
    'disabled' if disable || _.isEmpty(pdetails)

  customer: ->
    Template.instance().customer.get()

  address:  ->
    Template.instance().contact.get 'address'

  telephone: ->
    Template.instance().contact.get 'telephone'

  selector: ->
    Template.instance().selector.all()

  totals: ->
    Template.instance().totals.all()

  pselect: ->
    select: Template.instance().selectProduct

  iselect: ->
    select: Template.instance().selectInventory

  cselect: ->
    select: Template.instance().selectCustomer

  paidDisable: ->
    disabled: true if Template.instance().sell.get().paid

Template.SellsUpdate.events
  'click .js-add-detail': (event, instance) ->
    instance.selector.set('detail', true)
    instance.selector.set 'inventory', false
    instance.selector.set 'rinvent', false

  'focusin .js-add-customer': (event, instance) ->
    instance.selector.set('customer', true)

  'change .js-quantity': (event, instance) ->
    product_id = instance.$(event.target).closest('.js-pdetail').attr('data-id')
    pdetail = instance.pdetails.get(product_id)
    if _.isEmpty pdetail.inventories
      value = Number( instance.$(event.target).val() )
      if value > 0
        pdetail.quantity = value
        instance.pdetails.set(pdetail.product._id, pdetail)
      else
        instance.pdetails.delete(pdetail.product._id)
    else
      console.warn "Can't change quantity if there are inventories connected"
      instance.$(event.target).val(pdetail.quantity)
    instance.setTotals()


  'change .js-quantity-taken': (event, instance) ->
    product_id = instance.$(event.target).closest('.js-pdetail').attr('data-id')
    inventory_id = instance.$(event.target).closest('.js-inventory').attr('data-id')
    pdetail = instance.pdetails.get(product_id)
    value = Number( $(event.target).val() )
    if value > 0
      pdetail.inventories[inventory_id].quantity_taken = value
    else
      delete pdetail.inventories[inventory_id]
      pdetail.disabled = undefined if _.isEmpty pdetail.inventories

    pdetail.quantity = 0
    pdetail.quantity += value.quantity_taken for key, value of pdetail.inventories
    instance.pdetails.set(pdetail.product._id, pdetail)
    instance.setTotals()

  'click .js-remove-detail': (event, instance) ->
    product_id = instance.$(event.target).closest('.js-pdetail').attr('data-id')
    instance.pdetails.delete(product_id)
    instance.setTotals()

  'click .js-add-inventory': (event, instance) ->
    instance.selector.set 'inventory', true
    instance.selector.set 'detail', false
    instance.selector.set 'rinvent', false


  'click .js-remove-inventory': (event, instance) ->
    instance.selector.set 'inventory', false
    instance.selector.set 'detail', false
    instance.selector.set 'rinvent', false

    for key, value of instance.pdetails.all()
      unless _.isEmpty value.inventories
        instance.selector.set 'rinvent', true

    unless instance.selector.get 'rinvent'
      console.warn 'No inventories added yet'


  'click .js-inventory-select': (event, instance) ->
    value = instance.$(event.target).attr('data-id')
    instance.$('.js-remove-inven-input').val(value)


  'click .js-apply-remove': (event, instance) ->
    instance.selector.set 'rinvent', false
    inv_id = instance.$('.js-remove-inven-input').val()
    pdetails = instance.pdetails.all()
    for key, pdetail of pdetails
      if pdetail.inventories[inv_id]?
        pdetail.inventories[inv_id].quantity_taken--
        pdetail.quantity--
        delete pdetail.inventories[inv_id] if pdetail.inventories[inv_id].quantity_taken is 0
        instance.pdetails.set(pdetail.product._id, pdetail)
    instance.setTotals()

  'click .js-cancel-remove': (event, instance) ->
    instance.selector.set 'rinvent', false


  'change .js-discount-input': (event, instance) ->
    value = instance.$(event.target).val()
    instance.totals.set 'discount', Number(value)
    instance.$(event.target).val(value)
    instance.setTotals()

  'change .js-discount-type-select': (event, instance) ->
    value = Number instance.$(event.target).val()
    instance.totals.set 'discount_type', value
    instance.setTotals()


  'click .js-pay-button': (event, instance) ->
    instance.pay.set(true)
    if instance.$(event.target).hasClass('disabled')
      console.warn "Warn users every detail must have a scanned physical item"
      instance.pay.set(false)
    else
      instance.$('.js-sells-form-update').submit()


  'click .js-ship-here-b': (event, instance) ->
    index = instance.$(event.target).closest('.js-address-div').attr('data-index')
    customer = instance.customer.get()
    instance.contact.set 'address', customer.addresses[index]

  'click .js-new-shipping': (event, instance) ->
    ship =
      street: ''
      street2: ''
      city: ''
      state: ''
      zip_code: ''
      country: ''
    instance.contact.set 'address', ship

  'click .js-remove-address': (event, instance) ->
    instance.contact.set 'address', null

  'click .js-telephone-here-b': (event, instance) ->
    index = instance.$(event.target).closest('.js-telephone-div').attr('data-index')
    customer = instance.customer.get()
    instance.contact.set 'telephone', customer.telephones[index]

  'click .js-new-telephone': (event, instance) ->
    telephone =
      number: ''
    instance.contact.set 'telephone', telephone

  'click .js-remove-telephone': (event, instance) ->
    instance.contact.set 'telephone', null


  'submit .js-sells-form-update': (event, instance) ->
    event.preventDefault()
    classified = instance.classify()

    $form = instance.$('.js-sells-form-update')
    sell_doc =
      discount: instance.totals.get('discount')
      discount_type: instance.totals.get('discount_type')
      currency: $form.find('[name=currency]').val()
      details: classified.details
      status: $form.find('[name=status]').val()
      note: $form.find('[name=note]').val()
      customer_id: $form.find('[name=customer_id]').val()
      shipping_address: instance.contact.get('address')
      telephone: instance.contact.get('telephone')

    instance.done.set 'putback', false
    instance.done.set 'add', false
    instance.update sell_doc, classified.addInventories, classified.putBackInventories

  'mousedown .top': (event, instance) ->
    container = instance.$('.js-selector')
    if !container.is(event.target) && container.has(event.target).length is 0 && ( instance.selector.get('detail') || instance.selector.get('customer') || instance.selector.get('inventory') || instance.selector.get('rinvent') )
      instance.selector.set(detail: false, customer: false, inventory: false, rinvent: false)
