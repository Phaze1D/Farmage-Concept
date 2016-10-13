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
    @canLoadMore = true
    @autorun =>
        @page = Meteor.subscribeWithPagination "ingredients", organization_id, 'organization', organization_id, 12,
                  onStop: (err) ->
                    console.log "sub stop #{err}"
                  onReady: ->


  onRendered: ->
    super


  ingredients: ->
    IngredientModule.Ingredients.find()

  ready: ->
    if @page.ready()
      count = IngredientModule.Ingredients.find().count()
      if @previous is count
        @canLoadMore = false
      else
        @canLoadMore = true
        @previous = count
