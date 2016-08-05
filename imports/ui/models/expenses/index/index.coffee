IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class ExpensesIndex extends IndexMixin
  @register 'expenses.index'

  constructor: (args) ->
    super
