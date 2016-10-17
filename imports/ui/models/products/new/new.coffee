
PMethods = require '../../../../api/collections/products/methods.coffee'
ProductModule = require '../../../../api/collections/products/products.coffee'
DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'

require './new.jade'

class ProductsNew extends BlazeComponent
  @register 'productsNew'

  mixins: ->[
    DialogMixin
  ]

  constructor: (args) ->
    super

  onCreated: ->
    super
    @schema = ProductModule.Products.simpleSchema()

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')


  ingSchema: (_id) ->
    new SimpleSchema(
      "#{_id}":
        type: Number
        label: 'Resource'
        decimal: true
        min: 0
    )

  onCalcPrice: (event) ->
    upv = @find('.uprice .pinput').value
    tv = @find('.tax .pinput').value
    pv = 0
    tv = 0 unless tv?
    upv = 0 unless upv?
    tv = tv/100
    pv = upv * (1 + tv)
    @find('.tprice .pinput').value = pv.toFixed(2)

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);


  insert: (product_doc) ->
    product_doc.organization_id = FlowRouter.getParam('organization_id')
    PMethods.insert.call {product_doc}, (err, res) ->
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-product-new-form')
    ingredients = []

    for ing in @currentList('ingredients')
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
      'submit .js-product-new-form': @onSubmit
      'click .js-submit-new-product': @onSubmit
