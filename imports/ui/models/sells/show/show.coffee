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
    ['Information']

  date: (date) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

  customer: ->
    @data().sell.customer().fetch()[0]

  product: (product_id) ->
    ProductModule.Products.findOne product_id

  detailTotal: (detail) ->
    tp = detail.unit_price * (1 + (detail.tax_rate/100))
    tp.toFixed(2)

  hasInventories: (detail) ->
    detail.inventories.length > 0

  inventories: (detail) ->
    InventoryModule.Inventories.find()
