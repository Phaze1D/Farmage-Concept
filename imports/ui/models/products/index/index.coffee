IndexMixin = require '../../../mixins/index_mixin.coffee'
ProductModule = require '../../../../api/collections/products/products.coffee'


require './index.jade'

class ProductsIndex extends IndexMixin
  @register 'products.index'

  constructor: (args) ->
    super


  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "products", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  onRendered: ->
    super


  products: ->
    ProductModule.Products.find()
