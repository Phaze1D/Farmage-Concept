IngredientModule = require '../../../../api/collections/ingredients/ingredients.coffee'
IMethods = require '../../../../api/collections/ingredients/methods.coffee'

require './update.jade'

class IngredientsUpdate extends BlazeComponent
  @register 'ingredientsUpdate'

  constructor: (args) ->
    # body...

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  ingredient: ->
    IngredientModule.Ingredients.findOne @data().update_id
