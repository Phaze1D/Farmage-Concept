ShowMixin = require '../../../mixins/show_mixin.coffee'
require './show.jade'

class IngredientShow extends ShowMixin
  @register 'IngredientShow'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "timestamp", organization_id, @data().ingredient.created_user_id, @data().ingredient.updated_user_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  onRendered: ->
    super
    @parentComponent().parentComponent().parentComponent().rightData.set update_id: @data().ingredient._id


  tabs: ->
    ['Information', 'Analytics', 'Reports']

  products: ->
    @data().ingredient.products()

  pAmount: (product) ->
    for ing in product.pingredients
      if ing.ingredient_id is @data().ingredient._id
        return ing.amount
