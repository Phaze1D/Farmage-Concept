CardEvents = require '../../../mixins/card_events_mixin.coffee'

require './card.jade'

class IngredientCard extends BlazeComponent
  @register 'IngredientCard'

  mixins: -> [
    CardEvents
  ]


  onRendered: ->
    super
