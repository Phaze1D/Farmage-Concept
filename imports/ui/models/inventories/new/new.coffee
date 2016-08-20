DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'

IngredientModule= require '../../../../api/collections/ingredients/ingredients.coffee'


require './new.jade'


class InventoriesNew extends BlazeComponent
  @register 'inventoriesNew'

  constructor: (args) ->

  mixins: ->[
    EventMixin, DialogMixin
  ]

  onRendered: ->
    @autorun =>
      product = @product()
      if product?
        @subscribe "product.ingredients", product.organization_id, product._id,
          onStop: (err) ->
            console.log "sub stop #{err}"
          onReady: ->

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  product: ->
    @currentList('products')[0]

  yields: (ping) ->
    @currentList("yields#{ping.ingredient_id}")

  ingredient: (ping)->
    IngredientModule.Ingredients.findOne ping.ingredient_id


  onCloseDialogCallback: =>
