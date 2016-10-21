ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class ProductShow extends ShowMixin
  @register 'ProductShow'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "timestamp", organization_id, @data().product.created_user_id, @data().product.updated_user_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: =>

      @subscribe "ingredients", organization_id, 'product', @data().product._id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: =>



  onRendered: ->
    super
    @parentComponent().parentComponent().parentComponent().rightData.set
      update_id: @data().product._id

  tabs: ->
    ['Information', 'Analytics', 'Reports']

  totalPrice: ->
    tp = @data().product.unit_price * (1 + (@data().product.tax_rate/100))
    tp.toFixed(2)

  ingredients: ->
    @data().product.ingredients()

  ingAmount: (ingredient_id) ->
    for ing in @data().product.pingredients
      if ing.ingredient_id is ingredient_id
        return ing.amount
