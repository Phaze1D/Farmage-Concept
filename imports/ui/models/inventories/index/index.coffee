IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class InventoriesIndex extends IndexMixin
  @register 'inventories.index'

  constructor: (args) ->
    super
