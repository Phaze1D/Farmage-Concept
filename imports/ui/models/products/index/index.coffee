IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class ProductsIndex extends IndexMixin
  @register 'products.index'

  constructor: (args) ->
    super
