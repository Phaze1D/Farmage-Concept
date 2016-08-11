IndexMixin = require '../../../mixins/index_mixin.coffee'
IngredientModule = require '../../../../api/collections/ingredients/ingredients.coffee'

require './index.jade'

class IngredientsIndex extends IndexMixin
  @register 'ingredients.index'

  constructor: (args) ->
    super

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "ingredients", organization_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->


  onRendered: ->
    super


  ingredients: ->
    @resizeCard()
    IngredientModule.Ingredients.find()
