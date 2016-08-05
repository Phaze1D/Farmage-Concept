IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class YieldsIndex extends IndexMixin
  @register 'yields.index'

  constructor: (args) ->
    super
