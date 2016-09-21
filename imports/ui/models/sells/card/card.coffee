CustomerModule = require '../../../../api/collections/customers/customers.coffee'
CardEvents = require '../../../mixins/card_events_mixin.coffee'


require './card.jade'

class SellCard extends BlazeComponent
  @register 'SellCard'

  mixins: -> [
    CardEvents
  ]

  constructor: (args) ->


  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "sell.parents", organization_id, @data().sell._id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  customer: ->
    CustomerModule.Customers.findOne @data().sell.customer_id


  date: (date) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"
