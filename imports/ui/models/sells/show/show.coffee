ProductModule = require '../../../../api/collections/products/products.coffee'
InventoryModule = require '../../../../api/collections/inventories/inventories.coffee'


ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class SellShow extends ShowMixin
  @register 'SellShow'

  constructor: (args) ->
    super

  onCreated: ->
    super

  onRendered: ->
    super

  tabs: ->
    ['Information', 'Invoice']

  date: (date) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

  customer: ->
    @data().sell.customer().fetch()[0]

  product: (product_id) ->
    ProductModule.Products.findOne product_id

  detailTotal: (detail) ->
    tp = detail.unit_price * (1 + (detail.tax_rate/100))
    tp = tp * detail.quantity
    tp.toFixed(2)

  hasInventories: (detail) ->
    detail.inventories.length > 0

  inventories: (detail) ->
    invs = []
    for inv in detail.inventories
      inventory = InventoryModule.Inventories.findOne(_id: inv.inventory_id)
      inventory.quantity_taken = inv.quantity_taken
      invs.push inventory
    invs

  invIdentifer: (inventory) ->
    if inventory.name? then inventory.name else inventory._id

  invAmountTaken: (inventory_id) ->


  expand: (tar) ->
    expand = tar.prev()
    expand.velocity
      p: height: expand.find('.js-wrapper').height()
      o: duration: 250

    tar.find('i').velocity
      p: rotateZ: '180deg'
      o: duration: 250

  shrink: (tar) ->
    expand = tar.prev()
    expand.velocity
      p: height: 0
      o: duration: 250

    tar.find('i').velocity
      p: rotateZ: '0deg'
      o: duration: 250

  onToggleExpand: (event) ->
    tar = $(event.currentTarget)
    if tar.attr('expanded') is 'true'
      @shrink(tar)
      tar.attr('expanded', 'false')
    else
      @expand(tar)
      tar.attr('expanded', 'true')



  events: ->
    super.concat
      'click .js-expand-button': @onToggleExpand
