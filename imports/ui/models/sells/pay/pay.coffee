
require './pay.jade'


class SellPay extends BlazeComponent
  @register 'sellPay'

  onCreated: ->
    super

  products: ->
    @data().products

  pdetail: (product_id) ->
    detail = @data().pDetails.get product_id
    st = detail.unit_price * detail.quantity * (1 + (detail.tax_rate/100))
    detail.sub_total = st.toFixed(2)
    detail

  sellDoc: ->
    @data().sellDoc.get()

  discountType: ->
    @data().discount_type

  identifer: (inventory) ->
    if inventory.name?
      return inventory.name
    inventory._id

  quantityTaken: (inventory) ->
    dt = @data().pDetails.get inventory.product_id
    dt.inventories[inventory._id]


  inventories: ->
    @data().inventories

  productF: (product_id) ->
    for product in @products()
      if product._id is product_id
        return product

  onConfirm: (event) ->
    payment_method = $(@find '[name=payment_method]').val()
    payment_date = $(@find '[name=payment_date]').val()
    @data().onConfirmCallBack(payment_method, payment_date)

  events: ->
    super.concat
      'click .js-confirm-b': @onConfirm
