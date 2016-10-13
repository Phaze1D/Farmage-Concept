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
    @canLoadMore = true
    @autorun =>
        @page = Meteor.subscribeWithPagination "products", organization_id, 'organization', organization_id, 9,
                  onStop: (err) ->
                    console.log "sub stop #{err}"
                  onReady: ->

  onRendered: ->
    super


  products: ->
    ProductModule.Products.find()

  ready: ->
    if @page.ready()
      count = ProductModule.Products.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
