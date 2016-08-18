DialogMixin = require '../../../mixins/dialog_mixin/dialog_mixin.coffee'
EventMixin = require '../../../mixins/event_mixin/event_mixin.coffee'

require './new.jade'


class InventoriesNew extends BlazeComponent
  @register 'inventoriesNew'

  constructor: (args) ->

  mixins: ->[
    EventMixin, DialogMixin
  ]

  currentList: (subscription)->
    return @callFirstWith(@, 'currentList', subscription);
