ProductModule = require '../../../../api/collections/products/products.coffee'
CardEvents = require '../../../mixins/card_events_mixin.coffee'

require './card.jade'

class InventoryCard extends BlazeComponent
  @register 'InventoryCard'

  mixins: -> [
    CardEvents
  ]
    
  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "inventory.parents", organization_id, @data().inventory._id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  product: ->
    ProductModule.Products.findOne @data().inventory.product_id


  mEvents: ->
    events = []
    for i in [0..3]
      events.push {
        amount: Math.floor(Math.random() * 101) - 50;
      }
    events

  date: (date)->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

  identifer: ->
    if @data().inventory.name?
      @data().inventory.name
    else
      @data().inventory._id
