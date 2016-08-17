EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'

require './new.jade'


class InventoriesNew extends BlazeComponent
  @register 'inventoriesNew'
  
  constructor: (args) ->

  mixins: ->[
    EventMixin
  ]
