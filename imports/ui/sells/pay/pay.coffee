{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'

SellModule = require '../../../api/collections/sells/sells.coffee'
ProductModule = require '../../../api/collections/products/products.coffee'
CustomerModule = require '../../../api/collections/customers/customers.coffee'
SMethods = require '../../../api/collections/sells/methods.coffee'


require './pay.html'


Template.SellsPay.onCreated ->
  unsell_id = FlowRouter.getParam 'child_id'
  @autorun =>
    sell = SellModule.Sells.findOne unsell_id
    @subscribe 'sell.parents', sell.organization_id, sell._id

  @pay = (payment_method) =>
    sell_id = FlowRouter.getParam 'child_id'
    organization_id = FlowRouter.getParam 'organization_id'

    SMethods.pay.call {organization_id, sell_id, payment_method}, (err, res) =>
      console.log err
      params =
        organization_id: organization_id
        child_id: sell_id
      FlowRouter.go('sells.show', params) unless err?


Template.SellsPay.onRendered ->
  sell = SellModule.Sells.findOne FlowRouter.getParam 'child_id'
  if sell.paid
    params =
      organization_id: sell.organization_id
      child_id: sell._id
    FlowRouter.go 'sells.show', params


Template.SellsPay.helpers
  sell: ->
    SellModule.Sells.findOne FlowRouter.getParam 'child_id'

  product: (product_id) ->
    ProductModule.Products.findOne product_id

  customer: (customer_id) ->
    CustomerModule.Customers.findOne customer_id

  dtype: (discount_type) ->
    if discount_type then '%' else '$'



Template.SellsPay.events
  'submit .js-pay-form': (event, instance) ->
    event.preventDefault()
    payment_method = instance.$(event.target).find('[name=payment_method]').val()
    instance.pay payment_method
