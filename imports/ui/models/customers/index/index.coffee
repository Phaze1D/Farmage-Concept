IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class CustomersIndex extends IndexMixin
  @register 'customers.index'

  constructor: (args) ->
    super
