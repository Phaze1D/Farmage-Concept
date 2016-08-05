IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class EventsIndex extends IndexMixin
  @register 'events.index'

  constructor: (args) ->
