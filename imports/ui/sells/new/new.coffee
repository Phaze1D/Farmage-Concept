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

require '../../customers/selector/selector.coffee'
require '../../products/selector/selector.coffee'
require '../../inventories/selector/selector.coffee'
require './new.html'


Template.SellsNew.onCreated ->
  @selector = new ReactiveDict(detail: 'false', customer: 'false', inventory: 'false')
  @customer = new ReactiveVar
  @pdetails = new ReactiveDict


  @selectProduct = (product_id) =>
    product = ProductModule.Products.findOne product_id
    pdetail =
      product: product
      detail:
        quantity: 1
        inventories: {}
    @pdetails.set(product_id, pdetail) unless @pdetails.get(product_id)?
    @selector.set(detail: false, customer: false, inventory: false)


  @selectInventory = (inventory_id) =>
    inventory = InventoryModule.Inventories.findOne inventory_id
    dinventory =
      inventory: inventory
      quantity_taken: 1

    pdetail = @pdetails.get(inventory.product_id)
    if pdetail? && !pdetail.detail.inventories[inventory._id]
      pdetail.detail.inventories[inventory._id] = dinventory
      pdetail.detail.quantity = 0
      pdetail.detail.quantity += value.quantity_taken for key, value of pdetail.detail.inventories
      @pdetails.set(inventory.product_id, pdetail)

    unless pdetail?
      product = ProductModule.Products.findOne inventory.product_id
      if product?
        pdetail =
          product: product
          detail:
            quantity: 1
            inventories: {}
        pdetail.detail.inventories[inventory._id] = dinventory
        @pdetails.set(inventory.product_id, pdetail)
    @selector.set(detail: false, customer: false, inventory: false)


  @selectCustomer = (customer_id) =>
    customer = CustomerModule.Customers.findOne(customer_id)
    @customer.set(customer)
    @selector.set(detail: false, customer: false, inventory: false)

Template.SellsNew.helpers
  pdetails: ->
    pdetails = Template.instance().pdetails.all()
    (value for key, value of pdetails)

  inventories: (detail) ->
    (value for key, value of detail.inventories)

  customer: ->
    Template.instance().customer.get()

  selector: ->
    Template.instance().selector.all()

  pselect: ->
    select: Template.instance().selectProduct

  iselect: ->
    select: Template.instance().selectInventory

  cselect: ->
    select: Template.instance().selectCustomer

Template.SellsNew.events
  'click .js-add-detail': (event, instance) ->
    instance.selector.set('detail', true)
    instance.selector.set('inventory', true)

  'focusin .js-add-customer': (event, instance) ->
    instance.selector.set('customer', true)

  'change .js-quantity': (event, instance) ->
    product_id = $(event.target).closest('.js-pdetail').attr('data-productid')
    pdetail = instance.pdetails.get(product_id)
    if _.isEmpty pdetail.detail.inventories
      value = Number( $(event.target).val() )
      if value > 0
        pdetail.detail.quantity = value
        instance.pdetails.set(pdetail.product._id, pdetail)
      else
        instance.pdetails.delete(pdetail.product._id)
    else
      console.warn "Can't change quantity if there are inventories connected"
      $(event.target).val(pdetail.detail.quantity)


  'change .js-quantity-taken': (event, instance) ->
    product_id = $(event.target).closest('.js-pdetail').attr('data-productid')
    inventory_id = $(event.target).closest('.js-inventory').attr('data-inid')
    pdetail = instance.pdetails.get(product_id)
    value = Number( $(event.target).val() )
    if value > 0
      pdetail.detail.inventories[inventory_id].quantity_taken = value
      pdetail.detail.quantity = 0
      pdetail.detail.quantity += value.quantity_taken for key, value of pdetail.detail.inventories
    else
      delete pdetail.detail.inventories[inventory_id]
    instance.pdetails.set(pdetail.product._id, pdetail)

  'click .js-remove-detail': (event, instance) ->
    product_id = $(event.target).closest('.js-pdetail').attr('data-productid')
    instance.pdetails.delete(product_id)

  'click .js-add-inventory': (event, instance) ->
    instance.selector.set('inventory', true)

  'click .js-remove-inventory': (event, instance) ->
      product_id = $(event.target).closest('.js-pdetail').attr('data-productid')
      inventory_id = $(event.target).closest('.js-inventory').attr('data-inid')
      pdetail = instance.pdetails.get(product_id)
      console.log instance.pdetails.all()
      delete pdetail.detail.inventories[inventory_id]
      instance.pdetails.set(pdetail.product._id, pdetail)

  'mousedown .top': (event, instance) ->
    container = instance.$('.js-selector')
    instance.selector.set(detail: false, customer: false, inventory: false) if !container.is(event.target) &&
                                                                              container.has(event.target).length is 0 &&
                                                                              ( instance.selector.get('detail') ||
                                                                              instance.selector.get('customer') )
