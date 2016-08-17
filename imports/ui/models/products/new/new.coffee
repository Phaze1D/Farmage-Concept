
IngredientModule = require '../../../../api/collections/ingredients/ingredients.coffee'
PMethods = require '../../../../api/collections/products/methods.coffee'

require './new.jade'

class ProductsNew extends BlazeComponent
  @register 'productsNew'

  constructor: (args) ->
    super

  onCreated: ->
    super
    @showDialog = new ReactiveVar(false)
    @ingredients = new ReactiveVar([])


  dialogCB: ->
    ret =
      showClick: =>
        @showDialog.set true
      hideClick: =>
        @showDialog.set false

      beforeHide: @onCloseDialogCallback

  onCalcPrice: (event) ->
    upv = @find('.uprice .pinput').value
    tv = @find('.tax .pinput').value
    pv = 0
    tv = 0 unless tv?
    upv = 0 unless upv?
    tv = tv/100
    pv = upv * (1 + tv)
    @find('.tprice .pinput').value = pv.toFixed(2)


  onShowDialog: (event) ->
    $(@find('.js-open-dialog')).trigger('click')

  onCloseDialogCallback: =>
    ings = []
    $(".list-item[selected='true']").each ->
      ingredient_id = $(@).attr('data-id')
      ings.push IngredientModule.Ingredients.findOne ingredient_id

    @ingredients.set ings


  insert: (product_doc) ->
    product_doc.organization_id = FlowRouter.getParam('organization_id')
    PMethods.insert.call {product_doc}, (err, res) ->
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-product-new-form')
    ingredients = []
    for ing in @ingredients.get()
      ingredient_doc =
        ingredient_id: ing._id
        amount: $form.find("[name=#{ing._id}]").val()
      ingredients.push ingredient_doc
    product_doc =
      name: $form.find('[name=name]').val()
      size: $form.find('[name=size]').val()
      description: $form.find('[name=description]').val()
      sku: $form.find('[name=sku]').val()
      unit_price: $form.find('[name=unit_price]').val()
      currency: $form.find('[name=currency]').val()
      tax_rate: $form.find('[name=tax_rate]').val()
      pingredients: ingredients
    @insert product_doc



  events: ->
    super.concat
      'change .js-calc-p .pinput': @onCalcPrice
      'click .js-show-d': @onShowDialog
      'submit .js-product-new-form': @onSubmit
      'click .js-submit-new-product': @onSubmit
