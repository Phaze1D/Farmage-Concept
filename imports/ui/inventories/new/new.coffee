{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'
{ ReactiveDict } = require 'meteor/reactive-dict'


OrganizationModule = require '../../../api/collections/organizations/organizations.coffee'
InventoryModule = require '../../../api/collections/inventories/inventories.coffee'
ProductModule = require '../../../api/collections/products/products.coffee'
YieldModule = require '../../../api/collections/yields/yields.coffee'

require '../../products/selector/selector.coffee'
require '../../yields/selector/selector.coffee'
require './new.html'


Template.InventoriesNew.onCreated ->
  @selector = new ReactiveDict
  @yields = new ReactiveVar([])
  @product = new ReactiveVar

  @removeYield = (index) =>
    ylds = (_yield for _yield, i in @yields.get() when i isnt Number index )
    @yields.set ylds


  @selectYield = (yield_id) =>
    @selector.set('title', null)
    return for _yield in @yields.get() when _yield._id is yield_id

    ylds = @yields.get()
    ylds.push YieldModule.Yields.findOne yield_id
    @yields.set ylds


  @selectProduct = (product_id) =>
    @selector.set('title', null)
    @product.set ProductModule.Products.findOne product_id


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
