IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class SellsIndex extends IndexMixin
  @register 'sells.index'

  constructor: (args) ->
    super
