IndexMixin = require '../../../mixins/index_mixin.coffee'

require './index.jade'

class ProvidersIndex extends IndexMixin
  @register 'providers.index'

  constructor: (args) ->
    super
