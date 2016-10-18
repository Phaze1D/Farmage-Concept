PMethods = require '../../../../api/collections/products/methods.coffee'
ProductModule = require '../../../../api/collections/products/products.coffee'
IngredientModule = require '../../../../api/collections/ingredients/ingredients.coffee'



require './update.jade'

class ProductsUpdate extends BlazeComponent
  @register 'productsUpdate'

  onRendered: ->
    super
    $('#right-paper-header-panel').addClass('touchScroll')

  onCreated: ->
    super
    @schema = ProductModule.Products.simpleSchema()
    @totalPrice = new ReactiveVar()

  product: ->
    ProductModule.Products.findOne @data().update_id

  onCalcPrice: (event) ->
    product = @product()
    up = if @find('.uprice .pinput')? then @find('.uprice .pinput').value else product.unit_price
    tr = if @find('.tax .pinput')? then @find('.tax .pinput').value else product.tax_rate
    pv = 0
    tr = tr/100
    pv = up * (1 + tr)
    @totalPrice.set pv.toFixed(2)


  pingredients: ->
    @product().pingredients

  ingredient: (ingredient_id) ->
    IngredientModule.Ingredients.findOne ingredient_id

  update: (product_doc) ->
    organization_id = FlowRouter.getParam('organization_id')
    product_id = @data().update_id

    PMethods.update.call {organization_id, product_id, product_doc}, (err, res) =>
      console.log err
      $('.js-hide-new').trigger('click') unless err?


  onSubmit: (event) ->
    event.preventDefault()
    $form = $('.js-product-update-form')

    product_doc =
      name: $form.find('[name=name]').val()
      size: $form.find('[name=size]').val()
      description: $form.find('[name=description]').val()
      sku: $form.find('[name=sku]').val()
      unit_price: $form.find('[name=unit_price]').val()
      currency: $form.find('[name=currency]').val()
      tax_rate: $form.find('[name=tax_rate]').val()

    @update product_doc



  events: ->
    super.concat
      'input .js-calc-p .pinput': @onCalcPrice
      'submit .js-product-update-form': @onSubmit
      'click .js-submit-update-product': @onSubmit
