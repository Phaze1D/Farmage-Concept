
require './new.jade'

class ProductsNew extends BlazeComponent
  @register 'productsNew'

  constructor: (args) ->
    super

  onCreated: ->
    super
    @showDialog = new ReactiveVar(false)


  dialogCB: ->
    ret =
      showClick: =>
        @showDialog.set true
      hideClick: =>
        @showDialog.set false


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


  events: ->
    super.concat
      'change .js-calc-p .pinput': @onCalcPrice
      'click .js-show-d': @onShowDialog
