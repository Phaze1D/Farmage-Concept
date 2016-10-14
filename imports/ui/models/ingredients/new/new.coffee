
IMethods = require '../../../../api/collections/ingredients/methods.coffee'
IngredientModule = require '../../../../api/collections/ingredients/ingredients.coffee'


require './new.jade'


class IngredientsNew extends BlazeComponent
  @register 'ingredientsNew'

  constructor: (args) ->

  onCreated: ->
    super
    @schema = IngredientModule.Ingredients.simpleSchema()

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  insert: (ingredient_doc) ->
    ingredient_doc.organization_id = FlowRouter.getParam('organization_id')
    IMethods.insert.call {ingredient_doc}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err


  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-ingredient-new-form')
    ingredient_doc =
      name: $form.find('[name=name]').val()
      measurement_unit: $form.find('[name=measurement_unit]').val()
    @insert ingredient_doc


  events: ->
    super.concat
      'submit .js-ingredient-new-form': @onSubmit
      'click .js-submit-new-ingredient': @onSubmit
