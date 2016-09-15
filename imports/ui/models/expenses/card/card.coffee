UnitModule = require '../../../../api/collections/units/units.coffee'
ProviderModule = require '../../../../api/collections/providers/providers.coffee'



require './card.jade'

class ExpenseCard extends BlazeComponent
  @register 'ExpenseCard'

  constructor: (args) ->
    # body...

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "expense.parents", organization_id, @data().expense._id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  unit: ->
    UnitModule.Units.findOne @data().expense.unit_id

  provider: ->
    if @data().expense.provider_id?
      ProviderModule.Providers.findOne @data().expense.provider_id

  totalPrice: ->
    tp = @data().expense.price * @data().expense.quantity
    tp.toFixed(2)

  date: (date) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"
