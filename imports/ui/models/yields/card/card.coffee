UnitModule = require '../../../../api/collections/units/units.coffee'
IngredientModule = require '../../../../api/collections/ingredients/ingredients.coffee'
CardEvents = require '../../../mixins/card_events_mixin.coffee'



require './card.jade'

class YieldCard extends BlazeComponent
  @register 'YieldCard'

  mixins: -> [
    CardEvents
  ]


  constructor: (args) ->
    # body...

  onCreated: ->
    super
    organization_id = FlowRouter.getParam("organization_id")
    @autorun =>
      @subscribe "yield.parents", organization_id, @data().yield._id, @data().yield.unit_id,
        onStop: (err) ->
          console.log "sub stop #{err}"
        onReady: ->

  ingredient: ->
    IngredientModule.Ingredients.findOne @data().yield.ingredient_id

  unit: ->
    UnitModule.Units.findOne @data().yield.unit_id

  mEvents: ->
    events = []
    for i in [0..3]
      events.push {
        amount: Math.floor(Math.random() * 101) - 50;
      }
    events


  date: ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    date = @data().yield.createdAt
    "#{months[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

  identifer: ->
    if @data().yield.name?
      @data().yield.name
    else
      @data().yield._id
