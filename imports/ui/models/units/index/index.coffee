IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class UnitsIndex extends IndexMixin
  @register 'units.index'

  constructor: (args) ->
