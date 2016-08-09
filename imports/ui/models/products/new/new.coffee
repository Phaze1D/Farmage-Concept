
require './new.jade'

class ProductsNew extends BlazeComponent
  @register 'productsNew'

  constructor: (args) ->
    super


  calcPrice: (event) ->
    upv = @find('.uprice .pinput').value
    tv = @find('.tax .pinput').value
    pv = 0

    tv = 0 unless tv?
    upv = 0 unless upv?

    tv = tv/100
    pv = upv * (1 + tv)

    @find('.tprice .pinput').value = pv.toFixed(2)



  events: ->
    super.concat
      'change .js-calc-p .pinput': @calcPrice
