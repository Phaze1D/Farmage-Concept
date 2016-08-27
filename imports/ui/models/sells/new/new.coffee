
DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'

require './new.jade'


class SellsNew extends BlazeComponent
  @register 'sellsNew'

  mixins: -> [
    DialogMixin
  ]

  constructor: (args) ->
    # body...

  onCreated: ->
    super
    @discountDict = new ReactiveDict
    @discountDict.set('option', '%')
    @discountDict.set('value', true)

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);

  products: ->
    @currentList('products')

  discountType: ->
    @discountDict.all()

  onToggleDiscount: (event) ->
    if @discountDict.get('value')
      @discountDict.set('option', '$')
      @discountDict.set('value', false)
    else
      @discountDict.set('option', '%')
      @discountDict.set('value', true)

  events: ->
    super.concat
      'click .js-discount-select': @onToggleDiscount
